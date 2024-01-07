#!/bin/bash

this=$(realpath "$0")
cd "$(dirname "$this")"
protoc -I protos protos/*.proto --dart_out=grpc:lib/src/gen
