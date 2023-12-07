package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"net/http"
	"os/exec"
	"time"

	"github.com/gorilla/websocket"
)

var html = []byte(
	`<html>
	<head>
		<style>
			#code-block {
				background-color: black;
				height: 500px;
				width: 800px;
				padding: 15px;
				font: 1.3rem Inconsolata, monospace;
				color: white; 
				overflow: auto;
				overflow-x: hidden;
			}
			#code-container{
				display: flex;
            	justify-content: center;
            	align-items: center;
			}
			.inner-code {
				overflow-y: auto;
				height: 100%;
				color: white;
				scrollbar-width: bold;
				scrollbar-color: gray black; 
				margin-bottom: 5px;
			}
			.inner-code::-webkit-scrollbar {
				width: 12px; /* WebKit */
			}
			.inner-code::-webkit-scrollbar-thumb {
				background-color: gray; /* WebKit */
				border-radius: none; /* WebKit */
			}
			.inner-code::-webkit-scrollbar-track {
				background-color: black; /* WebKit */
			}
		</style>
	</head>
	<body>
		<h1>blah.exe</h1>
		<div id="code-container">
			<div id="code-block">
				<div class="inner-code" id="inner-code"></div>
			</div>
		</div>
		<script>
			var ws = new WebSocket("ws://127.0.0.1:9001/ws");
			var codeElement = document.getElementById("inner-code");

			ws.onmessage = function(e) {
				var isScrolledToBottom = codeElement.scrollHeight - codeElement.clientHeight <= codeElement.scrollTop + 1;
				
				codeElement.innerHTML += "> " + e.data + "<br>";

				if (isScrolledToBottom) {
					codeElement.scrollTop = codeElement.scrollHeight;
				}
			}
		</script>
	</body>
</html>
`)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func main() {
	http.HandleFunc("/ws", cmdToResponse)
	http.HandleFunc("/", serveHtml)

	log.Println("Listening on :9001")
	err := http.ListenAndServe(":9001", nil)
	if err != nil {
		log.Fatal(err)
	}
}

func cmdToResponse(w http.ResponseWriter, r *http.Request) {
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		w.Write([]byte(fmt.Sprintf("", err)))
		return
	}
	defer ws.Close()

	// discard received messages
	go func(c *websocket.Conn) {
		for {
			if _, _, err := c.NextReader(); err != nil {
				c.Close()
				break
			}
		}
	}(ws)

	ws.WriteMessage(1, []byte("Starting...\n"))

	// execute and get a pipe
	cmd := exec.Command("./vagExec")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Println(err)
		return
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		log.Println(err)
		return
	}

	if err := cmd.Start(); err != nil {
		log.Println(err)
		return
	}

	s := bufio.NewScanner(io.MultiReader(stdout, stderr))
	for s.Scan() {
		line := s.Bytes()
		ws.WriteMessage(1, line)
		time.Sleep(1 * time.Second)
	}

	if err := cmd.Wait(); err != nil {
		log.Println(err)
		return
	}

	ws.WriteMessage(1, []byte("Finished\n"))
}

func serveHtml(w http.ResponseWriter, r *http.Request) {
	w.Write(html)
}
