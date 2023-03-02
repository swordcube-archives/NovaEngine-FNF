@echo off
haxe docs/docs.hxml
haxelib run dox -i docs -o pages --title "Nova Engine Documentation" -ex .*^ -in backend/* -in game/* -in music/* -in objects/* -in states/*