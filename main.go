package main

/*
#cgo LDFLAGS: -framework Carbon
#include <stdlib.h>
extern void StartKeyCounter(int *counter);
extern void StopKeyCounter();
*/
import "C"
import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	startTime := time.Now()

	var minutes int
	flag.IntVar(&minutes, "m", 1, "Number of minutes to run")
	flag.Parse()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT)

	var counter C.int
	go C.StartKeyCounter(&counter)

	go func() {
		<-sigCh
		end(startTime, counter, minutes)
	}()

	for i := 0; i < minutes; i++ {
		time.Sleep(1 * time.Minute)
	}

	end(startTime, counter, minutes)
}

func end(start time.Time, counter C.int, minutes int) {
	C.StopKeyCounter()
	duration := time.Since(start).Minutes()
	avg := float64(counter) / float64(duration)
	fmt.Printf("Duration: %2f minutes. Total Presses: %d. Average per minute: %2f\n", duration, counter, avg)
	os.Exit(0)
}
