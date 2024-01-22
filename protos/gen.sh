#!/bin/bash

this=$(realpath "$0")
cd "$(dirname "$this")"
rm -f ./lib/src/gen/*
protoc -I protos protos/*.proto --dart_out=grpc:lib/src/gen
