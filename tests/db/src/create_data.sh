#!/bin/bash

curl -X POST "http://localhost:8000/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice Johnson", "email": "alice.johnson@example.com"}'

curl -X POST "http://localhost:8000/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Bob Smith", "email": "bob.smith@example.com"}'

curl -X POST "http://localhost:8000/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Charlie Brown", "email": "charlie.brown@example.com"}'