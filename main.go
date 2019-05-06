package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/gorilla/mux"
	"github.com/guregu/dynamo"
	"log"
	"math/rand"
	"net/http"
	"time"
)

type Quote struct {
	Quote    string
	Category string
}

func GetQuotes(w http.ResponseWriter, r *http.Request) {
	db := dynamo.New(session.New(), &aws.Config{Region: aws.String("us-west-1")})
	table := db.Table("Quotas")

	var results []Quote
	err := table.Scan().All(&results)
	if err != nil {
		fmt.Println(err)
		http.Error(w, err.Error(), 500)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(&results)
}

func GetQuote(w http.ResponseWriter, r *http.Request) {
	db := dynamo.New(session.New(), &aws.Config{Region: aws.String("us-west-1")})
	table := db.Table("Quotas")

	var quotas []Quote
	err := table.Scan().All(&quotas)
	if err != nil {
		fmt.Println(err)
		http.Error(w, err.Error(), 500)
	}

	rand.Seed(time.Now().UTC().UnixNano())
	n := rand.Int() % len(quotas)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(quotas[n])

}

func NewQuote(w http.ResponseWriter, r *http.Request) {
	db := dynamo.New(session.New(), &aws.Config{Region: aws.String("us-west-1")})
	table := db.Table("Quotas")
	var newq Quote
	_ = json.NewDecoder(r.Body).Decode(&newq)

	err := table.Put(newq).Run()
	if err != nil {
		fmt.Println(err)
		http.Error(w, err.Error(), 500)
	}
	json.NewEncoder(w).Encode(newq)
}

func GetRoot(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "form.html")
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/quotes", GetQuotes).Methods("GET")
	router.HandleFunc("/quote", GetQuote).Methods("GET")
	router.HandleFunc("/new", NewQuote).Methods("POST")
	router.HandleFunc("/", GetRoot).Methods("GET")
	log.Fatal(http.ListenAndServe(":8000", router))
}
