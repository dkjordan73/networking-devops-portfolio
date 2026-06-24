package main

import (
	"fmt"
	"net"
	"os"
	"time"
)

// CheckResult holds the results of a single port check
// Structs are like containers that group related data together
type CheckResult struct {
	Protocol string        // Name of what we're checking (HTTP, HTTPS, etc.)
	Port     string        // The port number (80, 443, etc.)
	Success  bool          // Did the connection work? true or false
	Duration time.Duration // How long did it take?
	Error    string        // If it failed, what was the error?
}

func main() {
	// Check if user provided a hostname
	if len(os.Args) < 2 {
		fmt.Println("Usage: netcheck <hostname>")
		fmt.Println("Example: netcheck google.com")
		os.Exit(1)
	}

	host := os.Args[1]

	// Define the protocols and ports we want to check
	// A slice is like a list that can grow or shrink
	protocols := []struct {
		name string
		port string
	}{
		{"HTTP", "80"},    // Regular web traffic
		{"HTTPS", "443"},  // Secure web traffic
		{"SSH", "22"},     // Secure shell (remote login)
		{"FTP", "21"},     // File transfer
		{"SMTP", "25"},    // Email sending
		{"MYSQL", "3306"}, // MySQL database
	}

	// This slice will hold all our results
	// We create it with a size to hold all checks we'll do
	results := make([]CheckResult, 0, len(protocols))

	fmt.Printf("🔍 Checking %s across multiple protocols...\n\n", host)

	// Loop through each protocol and check it
	// The 'range' keyword lets us go through each item in our slice
	for _, proto := range protocols {
		result := checkPort(host, proto.name, proto.port)
		results = append(results, result) // add this result to our results slice

		// Print the result to screen with nice formatting
		if result.Success {
			fmt.Printf("✔ %-10s (port %-5s) - Reachable in %v\n",
				result.Protocol, result.Port, result.Duration)
		} else {
			fmt.Printf("✖ %-10s (port %-5s) - Failed: %s\n",
				result.Protocol, result.Port, result.Error)
		}
	}

	//Now save all results to a file
	fmt.Println("\n💾 Saving results to file...")
	err := saveResults(host, results)
	if err != nil {
		fmt.Printf("⚠ Warning: Could not save to file: %v\n", err)
	} else {
		fmt.Printf("✔ Results saved to netcheck_%s.txt\n", host)
	}
}

// checkPort tries to connect to a specific port and returns the result
// This is a custom function we created; functions help organize code!
func checkPort(host, protocol, port string) CheckResult {
	// Create a result struct to store our findings
	result := CheckResult{
		Protocol: protocol,
		Port:     port,
		Success:  false, // Start assuming failure
	}

	// Set a timeout - we'll wait max 3 seconds
	timeout := 3 * time.Second

	// Record the start time so we can measure how long it takes
	start := time.Now()

	// Try to connect!
	// The net.JoinHostPort function properly combines host and port
	address := net.JoinHostPort(host, port)
	conn, err := net.DialTimeout("tcp", address, timeout)

	// Calculate how long it took
	result.Duration = time.Since(start)

	// Check if there was an error
	if err != nil {
		result.Success = false
		result.Error = err.Error() // Convert error to string
	} else {
		result.Success = true
		if conn != nil {
			conn.Close() // Important! Close the connection when done
		}
	}
	return result
}

// saveResults writes all the check results to a text file
// This teaches file I/O (Input/Output)
func saveResults(host string, results []CheckResult) error {
	// Create a filename based on the hostname
	filename := fmt.Sprintf("netcheck_%s.txt", host)

	// Create (or overwrite) the file
	// os.Create makes a new file, or clears an existing one
	// The '0644' is permissions: owner can read/write, others can only read
	file, err := os.Create(filename)
	if err != nil {
		return err // If we can't create the file, return the error
	}
	// 'defer' means "do this when the function ends"
	// This ensures we ALWAYS close the file, even if something goes wrong
	defer file.Close()

	// Write a header to the file
	header := fmt.Sprintf("Network Check Results for: %s\n", host)
	header += fmt.Sprintf("Checked on: %s\n", time.Now().Format("2006-01-02 15:04:05"))
	header += "=" + fmt.Sprintf("%50s", "") + "\n\n" // Divider line

	// WriteString writes text to the file
	_, err = file.WriteString(header)
	if err != nil {
		return err
	}

	// Write each result to the file
	for _, result := range results {
		var line string
		if result.Success {
			line = fmt.Sprintf("✔ %-10s (port %-5s) - SUCCESS - Response time: %v\n",
				result.Protocol, result.Port, result.Duration)
		} else {
			line = fmt.Sprintf("✖ %-10s (port %-5s) - FAILED - Error: %s\n",
				result.Protocol, result.Port, result.Error)
		}

		_, err = file.WriteString(line)
		if err != nil {
			return err
		}
	}

	// Write a summary at the end
	successCount := 0
	for _, result := range results {
		if result.Success {
			successCount++
		}
	}

	summary := "\n" + "=" + fmt.Sprintf("%50s", "") + "\n"
	summary += fmt.Sprintf("Summary: %d/%d ports reachable\n", successCount, len(results))

	_, err = file.WriteString(summary)
	return err // Return any error (or nil if successful)
}
