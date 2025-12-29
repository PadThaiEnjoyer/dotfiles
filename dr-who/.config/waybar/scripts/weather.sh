#!/bin/bash
# Pulls temperature and a small icon from wttr.in
curl -s "wttr.in?format=%t+%c" | tr -d '\n'
