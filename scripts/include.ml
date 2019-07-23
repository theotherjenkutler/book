(** Pandoc extension to include files. *)

let () =
  let p = Pandoc.of_json (Yojson.Basic.from_channel stdin) in
  let rec f = function
    (* !include "file" *)
    | `Para [`Str "!include"; _; `Quoted (`DoubleQuote, [`Str s])] ->
       let p = Pandoc.of_md_file s in
       List.flatten (List.map f p.blocks)
    (* ```{.blabla include="file"}
       ``` *)
    | `CodeBlock ((ident, classes, keyvals), _) when List.mem_assoc "include" keyvals ->
       let fname = List.assoc "include" keyvals in
       let from = try int_of_string (List.assoc "from" keyvals) with Not_found -> 0 in
       let contents =
         try
           let ic = open_in fname in
           let ans = ref "" in
           let line = ref 0 in
           try
             while true do
               if !line >= from then ans := !ans ^ input_line ic ^ "\n";
               incr line
             done;
             ""
           with
           | End_of_file -> !ans
         with
         | Sys_error _ -> "*** ERROR: file \""^fname^"\" not found! ***"
       in
       [`CodeBlock ((ident, classes, keyvals), contents)]
    | b ->  [b]
  in
  let p = Pandoc.map_top_blocks f p in
  let s = Yojson.Basic.pretty_to_string (Pandoc.to_json p) in
  Printf.printf "%s\n%!" s
