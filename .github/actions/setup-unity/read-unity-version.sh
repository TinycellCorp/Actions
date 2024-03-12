#!/bin/zsh

grep "^m_EditorVersion:" "ProjectSettings/ProjectVersion.txt" | cut -d " " -f2
