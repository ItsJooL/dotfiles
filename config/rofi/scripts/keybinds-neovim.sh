#!/usr/bin/env bash
# Rofi script mode: LazyVim keybindings (leader = Space)

if [[ -n "$1" ]]; then exit 0; fi

cat <<'EOF'
--- General ---
Save File                           Ctrl+S
Quit All                            Space qq
Lazy Plugin Manager                 Space l
New File                            Space fn
Clear Search Highlight              Esc
Open with System App                gx
--- Movement ---
Move Line Down                      Alt+J
Move Line Up                        Alt+K
--- Windows ---
Focus Left Window                   Ctrl+H
Focus Lower Window                  Ctrl+J
Focus Upper Window                  Ctrl+K
Focus Right Window                  Ctrl+L
Increase Window Height              Ctrl+Up
Decrease Window Height              Ctrl+Down
Decrease Window Width               Ctrl+Left
Increase Window Width               Ctrl+Right
--- Buffers ---
Next Buffer                         Shift+L  /  ]b
Prev Buffer                         Shift+H  /  [b
Switch to Alt Buffer                Space bb  /  Space `
Delete Buffer                       Space bd
Delete Other Buffers                Space bo
List Buffers                        Space ,  /  Space fb
--- Find / Files ---
Find Files (root)                   Space Space  /  Space ff
Find Files (cwd)                    Space fF
Find Git Files                      Space fg
Recent Files                        Space fr
Projects                            Space fp
--- Search / Grep ---
Grep (root)                         Space /  /  Space sg
Grep (cwd)                          Space sG
Grep Word Under Cursor              Space sw
Buffer Lines                        Space sb
Command History                     Space :
Help Pages                          Space sh
Keymaps                             Space sk
Marks                               Space sm
Resume Last Search                  Space sR
--- LSP ---
Goto Definition                     gd
References                          gr
Goto Implementation                 gI
Goto Type Definition                gy
Hover Documentation                 K
Rename                              Space cr
Code Action                         Space ca
Line Diagnostics                    Space cd
Document Symbols                    Space ss
Workspace Symbols                   Space sS
Symbols Outline                     Space cs
--- Diagnostics ---
Next Diagnostic                     ]d
Prev Diagnostic                     [d
Next Error                          ]e
Prev Error                          [e
Next Warning                        ]w
Prev Warning                        [w
Diagnostics (Trouble)               Space xx
Buffer Diagnostics (Trouble)        Space xX
--- Git ---
Git Status                          Space gs
Next Hunk                           ]h
Prev Hunk                           [h
Stage Hunk                          Space ghs
Reset Hunk                          Space ghr
Stage Buffer                        Space ghS
Preview Hunk                        Space ghp
Blame Line                          Space ghb
Blame Buffer                        Space ghB
--- File Explorer (Neo-tree) ---
Toggle Explorer (root)              Space e  /  Space fe
Toggle Explorer (cwd)               Space E  /  Space fE
Open / Expand                       l
Collapse                            h
Copy Path                           Y
--- UI Toggles ---
Toggle Format on Save               Space uf
Toggle Spelling                     Space us
Toggle Word Wrap                    Space uw
Toggle Line Numbers                 Space ul
Toggle Relative Numbers             Space uL
Toggle Diagnostics                  Space ud
Toggle Dark/Light Background        Space ub
Toggle Treesitter Highlight         Space uT
Toggle Inlay Hints                  Space uh
--- Editing ---
Toggle Line Comment                 gcc
Toggle Block Comment                gbc
Add Comment Below                   gco
Add Comment Above                   gcO
Indent and Reselect                 >  (visual)
Unindent and Reselect               <  (visual)
--- Surround (mini-surround) ---
Add Surrounding                     gsa
Delete Surrounding                  gsd
Replace Surrounding                 gsr
Find Surrounding (right)            gsf
Find Surrounding (left)             gsF
Highlight Surrounding               gsh
--- Annotations (neogen) ---
Generate Annotations                Space cn
--- Increment/Decrement (dial) ---
Increment                          Ctrl+A
Decrement                          Ctrl+X
--- Diff (mini-diff) ---
Toggle Diff Overlay                 Space go
--- Mini Files ---
Open Mini Files (file dir)          Space fm
Open Mini Files (cwd)               Space fM
--- Move (mini-move) ---
Move Line/Selection Left            Alt+H
Move Line/Selection Right           Alt+L
Move Line/Selection Down            Alt+J
Move Line/Selection Up              Alt+K
--- Outline ---
Toggle Outline                      Space cs
--- Java ---
Extract Variable                    Space cxv
Extract Constant                    Space cxc
Extract Method (visual)             Space cxm
Goto Super Implementation          Space cgs
Organize Imports                    Space co
--- Python ---
Debug Method                        Space dPt
Debug Class                         Space dPc
Select VirtualEnv                   Space cv
--- Rust ---
Rust Code Action                    Space cR
Rust Debuggables                    Space dr
--- Markdown ---
Markdown Preview                    Space cp
--- SQL ---
Toggle DBUI                         Space D
EOF
