(policy
  (annotation
    (identifier) @_id
    (string) @name)
  (effect) @context.extra
  (#eq? @_id "id")) @item

(policy
  . (effect) @name) @item
