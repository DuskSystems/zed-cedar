(namespace
  "namespace" @context
  (name) @name) @item

(entity_declaration
  "entity" @context
  (identifier_list
    (identifier) @name @item))

(action_declaration
  "action" @context
  (action_name_list
    (identifier) @name @item))

(common_type_declaration
  "type" @context
  (identifier) @name) @item
