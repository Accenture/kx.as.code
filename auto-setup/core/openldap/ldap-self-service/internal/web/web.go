package web

import (
	"fmt"
	"ldap-self-service/internal/yamlcustom"
	"net/http"
	"os/exec"
)

func execute(u string, op string, np string) error {
	conf := yamlcustom.ParseYAML()
	userDN := conf.Conf[0].UserDN
	ldapADDR := conf.Conf[1].LDAP

	// here we perform the pwd command.
	// we can store the output of this in our out variable
	// and catch any errors in err

	//out, err := exec.Command("ldappasswd", "-H", ldapADDR, "-x", "-D", "cn="+u+","+userDN, "-w", op, "-s", np).Output()
	cmd := "ldappasswd -H " + ldapADDR + " -x -D cn=" + u + "," + userDN + " -w " + op + " -s " + np
	out, err := exec.Command("bash", "-c", cmd).Output()

	// if there is an error with our execution
	// handle it here
	if err != nil {
		fmt.Printf("%s", err)
	}
	// as the out variable defined above is of type []byte we need to convert
	// this to a string or else we will see garbage printed out in our console
	// this is how we convert it to a string
	// fmt.Println("Command Successfully Executed")
	output := string(out)
	fmt.Println(output)

	return err
}

func FormHandler(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		fmt.Fprintf(w, "ParseForm() err: %v", err)
		return
	}
	fmt.Fprintf(w, "POST request successful\n")
	username := r.FormValue("username")
	oldPassword := r.FormValue("oldpassword")
	newPassword := r.FormValue("newpassword")

	result := execute(username, oldPassword, newPassword)
	sucess := "Successful"

	if result != nil {
		fmt.Fprintf(w, "Status = %s\n", result)
	} else {
		fmt.Fprintf(w, "Status = %s\n", sucess)
	}
}
