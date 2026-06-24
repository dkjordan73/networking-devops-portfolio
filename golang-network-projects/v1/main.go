package main

import (
	"fmt"
	"net"
	"os"
	"time"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: netcheck <hostname>")
		os.Exit(1)
	}

	host := os.Args[1]

	timeout := 3 * time.Second
	_, err := net.DialTimeout("tcp", host+":80", timeout)

	if err != nil {
		fmt.Printf("✖ Host %s is not reachable (%v)\n", host, err)
		os.Exit(1)
	}

	fmt.Printf("✔ Host %s is reachable\n", host)
}
