#!/bin/zsh

grep "^m_EditorVersion:" "$1/ProjectSettings/ProjectVersion.txt" | cut -d " " -f2
