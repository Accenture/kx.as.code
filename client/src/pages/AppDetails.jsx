import React, { useState, useEffect } from "react";
import NotFound from "../partials/NotFound";
import metadata from "../data/metadata.json";

export default function AppDetails() {
  const [data, setData] = useState([]);

  // TODO fetching from entdoint
  const getData = () => {
    fetch("/data/metadata.json", {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    })
      .then(function (response) {
        console.log(response);
        return response.json();
      })
      .then(function (myJson) {
        console.log(myJson);
        setData(myJson);
      });
  };
  useEffect(() => {
    setData(metadata);
    console.log("metadata: ", metadata);
  }, []);
  return (
    <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto text-white">
      App Details Page
      <NotFound />
    </div>
  );
}
