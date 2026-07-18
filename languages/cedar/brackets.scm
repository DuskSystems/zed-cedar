("(" @open
  ")" @close)

("[" @open
  "]" @close)

("{" @open
  "}" @close)

(string
  "\"" @open
  "\"" @close)

(type_reference
  "<" @open
  ">" @close)
