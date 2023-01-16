@echo off
haxe docs/docs.hxml
haxelib run dox -i docs -o pages --title "Nova Engine Documentation" -ex .*^ -in core/* -in funkin/* -in scripting/*