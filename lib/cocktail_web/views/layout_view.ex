defmodule CocktailWeb.LayoutView do
  use CocktailWeb, :view

  @html_elements ["a", "abbr", "address", "area", "article", "aside", "audio", "b", "base", "bdi", "bdo", "blockquote", "body", "br", "button", "canvas", "caption", "cite", "code", "col", "colgroup", "data", "datalist", "dd", "del", "details", "dfn", "dialog", "div", "dl", "dt", "em", "embed", "fieldset", "figcaption", "figure", "footer", "form", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html", "i", "iframe", "img", "input", "ins", "kbd", "keygen", "label", "legend", "li", "link", "main", "map", "mark", "math", "menu", "menuitem", "meta", "meter", "nav", "noscript", "object", "ol", "optgroup", "option", "output", "p", "param", "picture", "pre", "progress", "q", "rb", "rp", "rt", "rtc", "ruby", "s", "samp", "script", "section", "select", "slot", "small", "source", "span", "strong", "style", "sub", "summary", "sup", "svg", "table", "tbody", "td", "template", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "track", "u", "ul", "var", "video", "wbr"]

  @atomified_html_elements Enum.reduce(@html_elements, [], fn(el, acc) ->
    [String.to_atom(el) | acc]
  end)

  @months_numbers 1..12
  @months_names ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  Enum.zip(@months_numbers, @months_names)
  |> Enum.each(fn({numb, name}) ->
    def month_to_human(unquote(numb)), do: unquote(name)
  end)

  defmacro atomified_elements(), do: @atomified_html_elements

  defmacro tags_most_common() do
    {:safe, [Enum.reduce(
      (Cocktail.Element.HTML.Tag.most_common(:string) |> Enum.reverse()),
        ['<optgroup label="--------------">'],
        fn(tag, acc) ->
          ['<option value="', tag, '">', tag, '</option>' | acc]
        end
      ) | '</optgroup>']
    }
  end

  defmacro tags_remaining() do
    {:safe, Enum.reduce(
      (Cocktail.Element.HTML.Tag.without_most_common(:string) |> Enum.reverse()),
        [],
        fn(tag, acc) ->
          ['<option value="', tag, '">', tag, '</option>' | acc]
        end
      )
    }
  end

  defmacro tags_select_options() do
    {:safe, Enum.reduce((Cocktail.Element.HTML.Tag.all_tags(:string) |> Enum.reverse()), [], fn(tag, acc) ->
      ['<option value="', tag, '">', tag, '</option>' | acc]
    end)}
  end

  def build_classes_main(classes, false), do: Enum.join(classes, " ")
  def build_classes_main(classes, _), do: Enum.join(["cocktail-highlight" | classes], " ")
  def build_styles(styles), do: Enum.map(styles, fn({k, v}) -> "#{k}: #{v}" end) |> Enum.join(";")

  def add_attributes_list(id, chain, attrs, style, classes, is_selected) do
    [
      {:cocktail, 1},
      {:id, id},
      {:"cocktail-chain", Jason.encode!(:lists.reverse(chain))},
      {:style, build_styles(style)},
      {:class, Enum.join(
          if(is_selected, do: ["cocktail-highlight" | classes], else: classes), " "
        )
      },
      {:"phx-click", "select"}
      | attrs
    ]
  end

  def add_attributes_published_list(id, attrs, style, classes) do
    [
      {:id, id},
      {:style, build_styles(style)},
      {:class, Enum.join(classes, " ")}
      | attrs
    ]
  end

  def cocktail_published_tag(
    %{
      tag: :div,
      id: el_id,
      body: [_|_] = body,
      content: "",
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    conn, additional
  ) do

    content_tag(:div, Phoenix.HTML.raw(
          for contents <- body do
            safe_to_string(
              render(
                conn, "element.html",
                contents: contents,
                conn: conn,
                additional: additional
              )
            )
          end
        ),
      add_attributes_published_list(el_id, attrs, style, classes)
    )
  end

  def cocktail_published_tag(
    %{
      tag: :div,
      body: [_|_] = body,
      id: el_id,
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    conn, additional
  ) do
    
    content_tag(:div, Phoenix.HTML.raw(
          "#{content}#{(
            for contents <- body do 
              safe_to_string(render(conn, "element.html", contents: contents, conn: conn, additional: additional))
            end
          )}"
        ),
      add_attributes_published_list(el_id,  attrs, style, classes)
    )
  end

  def cocktail_published_tag(
    %{
      tag: :div,
      id: el_id,
      body: [],
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    _conn, _additional) do
    content_tag(:div, Phoenix.HTML.raw(content), add_attributes_published_list(el_id, attrs, style, classes))
  end

  def cocktail_published_tag(
    %{
      tag: :a,
      id: el_id,
      body: body,
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    _conn, _additional) do
    
    content_tag(:a, Phoenix.HTML.raw(content), add_attributes_published_list(el_id, attrs, style, classes))
  end

  def cocktail_published_tag(
    %{
      tag: tag,
      id: el_id,
      body: [],
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    _conn, _additional) when tag in @atomified_html_elements do

    content_tag(tag, Phoenix.HTML.raw(content), add_attributes_published_list(el_id, attrs, style, classes))
  end

  def cocktail_published_tag(
    %{
      tag: tag,
      id: el_id,
      body: [],
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    _conn, _additional) do

    tag(tag, add_attributes_published_list(el_id, attrs, style, classes))
  end

  ###################
  ###################
  
  ###################
  ###################

  def cocktail_tag(
    %{
      tag: :div,
      id: el_id,
      body: [_|_] = body,
      content: "",
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    socket, chain, page_id, selected) do
    
    content_tag(:div, Phoenix.HTML.raw(
          for %{id: id} = contents <- body do
            safe_to_string(
              live_render(
                socket, Cocktail.View.Element,
                session: %{
                  section: :div,
                  contents: contents,
                  id: id,
                  chain: [el_id | chain],
                  selected: selected,
                  page_id: page_id
                },
                child_id: id
              )
            )
          end
        ),
      add_attributes_list(el_id, chain, attrs, style, classes, selected == el_id)
    )
  end

  def cocktail_tag(
    %{
      tag: :div,
      body: [_|_] = body,
      id: el_id,
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    socket, chain, page_id, selected) do
    
    content_tag(:div, Phoenix.HTML.raw(
          "#{content}#{(
            for %{id: id} = contents <- body do 
              safe_to_string(live_render(socket, Cocktail.View.Element, session: %{section: :div, contents: contents, id: id, chain: [el_id | chain], selected: selected, page_id: page_id}, child_id: id))
            end
          )}"
        ),
      add_attributes_list(el_id, chain, attrs, style, classes, selected == el_id)
    )
  end

  def cocktail_tag(
    %{
      tag: :div,
      id: el_id,
      body: [],
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    _socket, chain, _page_id, selected) do
    
    content_tag(:div, Phoenix.HTML.raw(content), add_attributes_list(el_id, chain, attrs, style, classes, selected == el_id))
  end

  def cocktail_tag(
    %{
      tag: :a,
      id: el_id,
      body: body,
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    _socket, chain, _page_id, selected) do
    
    content_tag(:a, Phoenix.HTML.raw(content), add_attributes_list(el_id, chain, Keyword.delete(attrs, :href), style, classes, selected == el_id))
  end

  def cocktail_tag(
    %{
      tag: tag,
      id: el_id,
      body: [],
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    _socket, chain, _page_id, selected) when tag in @atomified_html_elements do

    content_tag(tag, Phoenix.HTML.raw(content), add_attributes_list(el_id, chain, attrs, style, classes, selected == el_id))
  end

  def cocktail_tag(
    %{
      tag: tag,
      id: el_id,
      body: [],
      content: content,
      attrs: attrs,
      style: style,
      classes: classes,
      interactions: _interactions
    },
    _socket, chain, _page_id, selected) do

    tag(tag, add_attributes_list(el_id, chain, attrs, style, classes, selected == el_id))
  end

  def export_js(path) do
    n_path = case path do
               "/" <> _ -> path
               _ -> "/" <> path
             end
    File.read!(Path.absname("priv/static#{n_path}", Application.app_dir(:cocktail)))
  end
end
