defmodule Cocktail.Operations do
  @default_id "editor-main-body-container"


  def select_parent(%{selected: %{full_chain: id} = selected} = page) do
    case id do
      [@default_id] -> selected
      _ ->
        new_chain = List.delete_at(id, -1)
        select(new_chain, page)
        |> Map.put(:full_chain, new_chain)
    end
  end

  def select_next_sibling(%{selected: %{next_sib: false} = selected} = page), do: selected
  def select_next_sibling(%{selected: %{full_chain: id, next_sib: next_sib} = selected} = page) do
    new_chain =
      List.delete_at(id, -1)
      |> List.insert_at(-1, next_sib)
    
    select(new_chain, page)
    |> Map.put(:full_chain, new_chain)
  end

  def select_previous_sibling(%{selected: %{previous_sib: false} = selected} = page), do: selected
  def select_previous_sibling(%{selected: %{full_chain: id, previous_sib: prev_sib} = selected} = page) do
    new_chain =
      List.delete_at(id, -1)
      |> List.insert_at(-1, prev_sib)
    
    select(new_chain, page)
    |> Map.put(:full_chain, new_chain)
  end

  def select_child(%{selected: %{full_chain: id} = selected} = page) do
    case select(id, page, false, false, true) do
      %{body: [%{id: el_id} = h, %{id: next_sib} | t]} ->
        extract_selected(h, false, next_sib, false)
        |> Map.put(:full_chain, id ++ [el_id])

      %{body: [%{id: el_id} = h | t]} ->
        extract_selected(h, false, false, false)
        |> Map.put(:full_chain, id ++ [el_id])

      _ -> selected
    end
  end

  def default_selected(page) do
    select([@default_id], page)
    |> add_default_chain()
  end

  def add_default_chain(selected) do
    Map.put(selected, :full_chain, [@default_id])
  end

  def content([@default_id], page, _), do: page

  def content([@default_id | t], %{body: body} = page, content_n_type) do
    %{page | body: content(t, body, content_n_type)}
  end

  def content([el], [%{id: el} = full | t], {content, type}) do
    [%{full | content: content} | t]
  end

  def content([el | el_t], [%{id: el, body: body} = full | t], content_n_type) do
    [%{full | body: content(el_t, body, content_n_type)} | t]
  end

  def content([el | _] = target, [h | t], content_n_type), do: [h | content(target, t, content_n_type)]

  def select(chain, page, prev \\ false, next \\ false, keep_body \\ false)
  def select([], page, _, _, keep_body),
    do: extract_selected(page, false, false, keep_body)
    
  def select([@default_id], page, _, _, keep_body),
    do: extract_selected(page, false, false, keep_body)
  
  def select([@default_id | t], %{body: body}, _, _, keep_body),
    do: select(t, body, false, false, keep_body)
  
  def select([el], [%{id: el} = full | t], prev, _, keep_body),
    do: extract_selected(full, prev, check_if_next_sibling(t), keep_body)
  
  def select([el | el_t], [%{id: el, body: body} | t], prev, _, keep_body),
    do: select(el_t, body, false, false, keep_body)
  
  def select(target, [%{id: prev_id} | t], prev, _, keep_body),
    do: select(target, t, prev_id, false, keep_body)


  def move_prev(%{body: body, selected: %{full_chain: id}} = page) do
    case List.pop_at(id, -1) do
      {_, []} -> page
      {el_id, parent_chain} -> move_prev(parent_chain, body, el_id)
    end
  end
   
  def move_prev([@default_id], existing, id) do
    case Enum.find_index(existing, fn(%{id: el_id}) -> el_id == id end) do
      0 -> existing
      index ->
        {element, n_existing} = List.pop_at(existing, index)
        List.insert_at(n_existing, index - 1, element)
    end
  end
    
  def move_prev([@default_id | t], existing, id), do: move_prev(t, existing, id)
  def move_prev([el], [%{id: el, body: body} = full | t], id) do
    case Enum.find_index(body, fn(%{id: el_id}) -> el_id == id end) do
      0 -> [full | t]
      index ->
        {element, n_body} = List.pop_at(body, index)
        n_body_2 = List.insert_at(n_body, index - 1, element)
        [%{full | body: n_body_2} | t]
    end
  end

  def move_prev([el | el_t], [%{id: el, body: body} = full | t], id) do
    [%{full | body: move_prev(el_t, t, id)} | t]
  end

  def move_prev([el | _] = target, [h | t], id) do
    [h | move_prev(target, t, id)]
  end

  def move_prev(%{body: body, selected: %{full_chain: id}} = page) do
    case List.pop_at(id, -1) do
      {_, []} -> body
      {el_id, parent_chain} -> move_prev(parent_chain, body, el_id)
    end
  end

  def move_next(%{body: body, selected: %{full_chain: id}} = page) do
    case List.pop_at(id, -1) do
      {_, []} -> page
      {el_id, parent_chain} -> move_next(parent_chain, body, el_id)
    end
  end
   
  def move_next([@default_id], existing, id) do
    index = Enum.find_index(existing, fn(%{id: el_id}) -> el_id == id end)
    {element, n_existing} = List.pop_at(existing, index)
    List.insert_at(n_existing, index + 1, element)
  end
    
  def move_next([@default_id | t], existing, id), do: move_next(t, existing, id)
  def move_next([el], [%{id: el, body: body} = full | t], id) do
    index = Enum.find_index(body, fn(%{id: el_id}) -> el_id == id end)
    {element, n_body} = List.pop_at(body, index)
    n_body_2 = List.insert_at(n_body, index + 1, element)
    [%{full | body: n_body_2} | t]
  end

  def move_next([el | el_t], [%{id: el, body: body} = full | t], id) do
    [%{full | body: move_next(el_t, t, id)} | t]
  end

  def move_next([el | _] = target, [h | t], id) do
    [h | move_next(target, t, id)]
  end

  def add(tag, [], existing), do: existing
  def add(tag, [@default_id], existing), do:  append_tag(tag, existing)
  def add(tag, [@default_id | t], existing), do: add(tag, t, existing)

  def add(tag, [el], [%{id: el, body: body} = full | t]), do: [%{full | body: append_tag(tag, body)} | t]

  def add(tag, [el | el_t], [%{id: el, body: body} = full | t]), do: [%{full | body: add(tag, el_t, body)} | t]

  def add(tag, [el | _] = target, [h | t]), do: [h | add(tag, target, t)]

  def append_tag(tag, existing), do: Enum.concat(existing, [create(tag)])

  def create({:component, component}), do: Cocktail.Element.from_component(component)
  def create(tag), do: Cocktail.Element.create_default(tag)

  def delete([@default_id], existing), do: existing
  def delete([@default_id | t], existing), do: delete(t, existing)
  def delete([el], [%{id: el} | t]), do: t
  def delete([el | chain_t], [%{id: el, body: body} = full | t]), do: [%{full | body: delete(chain_t, body)} | t]
  def delete([el | _] = target, [h | t]), do: [h | delete(target, t)]

  def style_children([@default_id], %{body: body} = full, prop_value) do
    %{
      full |
      body: Enum.map(body, fn(%{id: id} = child) ->
        style([id], [child], prop_value)
        |> elem(0)
        |> List.first()
      end)
    }
  end
  
  def style_children([@default_id | t], %{body: body} = full, prop_value) do
    %{full | body: style_children(t, body, prop_value)}
  end

  def style_children([el], [%{id: el, body: body} = full | t], prop_value) do
    [
      %{
        full |
        body: Enum.map(body, fn(%{id: id} = child) ->
          style([id], [child], prop_value)
          |> elem(0)
          |> List.first()
        end)
      }
      | t
    ]
  end

  def style_children([el | el_t], [%{id: el, body: body} = full | t], prop_value),
    do: [%{full | body: style_children(el_t, body, prop_value)} | t]

  def style_children([el | _] = target, [h | t], prop_value),
  do: [h | style_children(target, t, prop_value)]

  def style(target, body, prop_value, delete \\ false)
  def style([@default_id], %{style: style, selected: selected} = full, {prop, _} = prop_value, delete) do
    new_styles = case Enum.reject(style, fn
                       ({^prop, _}) -> true
                       (_) -> false
                     end) do
                   n_styles when delete -> n_styles
                   n_styles -> [prop_value | n_styles]
                 end
    
    %{full | style: new_styles, selected: %{selected | style: new_styles}}
  end

  def style([@default_id | t], %{body: body, selected: selected} = full, prop_value, delete) do
    {n_body, new_styles} = style(t, body, prop_value, delete)
    %{full | body: n_body, selected: %{selected | style: new_styles}}
  end

  def style([el], [%{id: el, style: style} = full | t], {prop, _} = prop_value, delete) do
    new_styles = case Enum.reject(style, fn
                       ({^prop, _}) -> true
                       (_) -> false
                     end) do
                   n_styles when delete -> n_styles
                   n_styles -> [prop_value | n_styles]
                 end
    
    {[%{full | style: new_styles} | t], new_styles}
  end

  def style([el | el_t], [%{id: el, body: body} = full | t], prop_value, delete) do
    {n_body, n_styles} = style(el_t, body, prop_value, delete)
    {[%{full | body: n_body} | t], n_styles}
  end

  def style([_el | _] = target, [h | t], prop_value, delete) do
    {n_inner, n_styles} = style(target, t, prop_value, delete)
    {[h | n_inner], n_styles}
  end

  def class_children([@default_id], %{body: body} = full, classes) do
    %{
      full |
      body: Enum.map(body, fn(%{id: id} = child) ->
        class([id], [child], classes)
        |> elem(0)
        |> List.first()
      end)
    }
  end
  
  def class_children([@default_id | t], %{body: body} = full, classes) do
    %{full | body: class_children(t, body, classes)}
  end

  def class_children([el], [%{id: el, body: body} = full | t], classes) do
    [
      %{
        full |
        body: Enum.map(body, fn(%{id: id} = child) ->
          class([id], [child], classes)
          |> elem(0)
          |> List.first()
        end)
      }
      | t
    ]
  end

  def class_children([el | el_t], [%{id: el, body: body} = full | t], classes),
    do: [%{full | body: class_children(el_t, body, classes)} | t]

  def class_children([el | _] = target, [h | t], classes),
  do: [h | class_children(target, t, classes)]

  def class(target, body, classes, delete \\ false)
  def class([@default_id], %{classes: e_classes, selected: selected} = full, classes, delete) do
    new_classes = case Enum.reject(e_classes, fn(class) -> class in classes end) do
                    n_classes when delete -> n_classes
                    n_classes -> [classes | n_classes]
                  end |> :lists.flatten()
    
    %{full | classes: new_classes, selected: %{selected | classes: new_classes}}
  end

  def class([@default_id | t], %{body: body, selected: selected} = full, classes, delete) do
    {n_body, new_classes} = class(t, body, classes, delete)
    %{full | body: n_body, selected: %{selected | classes: new_classes}}
  end

  def class([el], [%{id: el, classes: e_classes} = full | t], classes, delete) do
    new_classes = case Enum.reject(e_classes, fn(class) -> class in classes end) do
                    n_classes when delete -> n_classes
                    n_classes -> [classes | n_classes]
                  end |> :lists.flatten()
    
    {[%{full | classes: new_classes} | t], new_classes}
  end

  def class([el | el_t], [%{id: el, body: body} = full | t], classes, delete) do
    {n_body, n_classes} = class(el_t, body, classes, delete)
    {[%{full | body: n_body} | t], n_classes}
  end

  def class([_el | _] = target, [h | t], classes, delete) do
    {n_inner, n_classes} = class(target, t, classes, delete)
    {[h | n_inner], n_classes}
  end

  def extract_selected(%Cocktail.Element{} = element, prev, next, kb) do
    Map.from_struct(element)
    |> Map.put(:title, false)
    |> add_prev_next(prev, next)
    |> maybe_keep_body(kb)
  end

  def extract_selected(%Cocktail.Page{} = element, prev, next, kb) do
    Map.from_struct(element)
    |> add_prev_next(prev, next)
    |> maybe_keep_body(kb)
  end

  def extract_selected(%{title: _} = element, prev, next, kb) do
    element
    |> add_prev_next(prev, next)
    |> maybe_keep_body(kb)
  end
  
  def extract_selected(element, prev, next, kb) do
    element
    |> Map.put(:title, false)
    |> add_prev_next(prev, next)
    |> maybe_keep_body(kb)
  end

  def maybe_keep_body(element, true), do: element
  def maybe_keep_body(element, false) do
    element
    |> Map.pop(:body)
    |> elem(1)
  end

  def add_prev_next(element, prev, next) do
    element
    |> Map.put(:previous_sib, prev)
    |> Map.put(:next_sib, next)
  end

  def check_if_next_sibling([%{id: id} | _]), do: id
  def check_if_next_sibling(_), do: false

end
