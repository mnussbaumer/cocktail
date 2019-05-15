defmodule Cocktail.Element.HTML.Tag do
  @behaviour Ecto.Type
  def type, do: :string

  @valid_tags_string ["a", "abbr", "acronym", "address", "applet", "area", "article", "aside", "audio", "b", "base", "basefont", "bdi", "bdo", "bgsound", "big", "blink", "blockquote", "body", "br", "button", "canvas", "caption", "center", "cite", "code", "col", "colgroup", "command", "content", "data", "datalist", "dd", "del", "details", "dfn", "dialog", "dir", "div", "dl", "dt", "element", "em", "embed", "fieldset", "figcaption", "figure", "font", "footer", "form", "frame", "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html", "i", "iframe", "image", "img", "input", "ins", "isindex", "kbd", "keygen", "label", "legend", "li", "link", "listing", "main", "map", "mark", "marquee", "math", "menu", "menuitem", "meta", "meter", "multicol", "nav", "nextid", "nobr", "noembed", "noframes", "noscript", "object", "ol", "optgroup", "option", "output", "p", "param", "picture", "plaintext", "pre", "progress", "q", "rb", "rbc", "rp", "rt", "rtc", "ruby", "s", "samp", "script", "section", "select", "shadow", "slot", "small", "source", "spacer", "span", "strike", "strong", "style", "sub", "summary", "sup", "svg", "table", "tbody", "td", "template", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "track", "tt", "u", "ul", "var", "video", "wbr", "xmp"]

  @valid_open_tags_string ["a", "abbr", "address", "area", "article", "aside", "audio", "b", "base", "bdi", "bdo", "blockquote", "body", "br", "button", "canvas", "caption", "cite", "code", "col", "colgroup", "data", "datalist", "dd", "del", "details", "dfn", "dialog", "div", "dl", "dt", "em", "embed", "fieldset", "figcaption", "figure", "footer", "form", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html", "i", "iframe", "img", "input", "ins", "kbd", "keygen", "label", "legend", "li", "link", "main", "map", "mark", "math", "menu", "menuitem", "meta", "meter", "nav", "noscript", "object", "ol", "optgroup", "option", "output", "p", "param", "picture", "pre", "progress", "q", "rb", "rp", "rt", "rtc", "ruby", "s", "samp", "script", "section", "select", "slot", "small", "source", "span", "strong", "style", "sub", "summary", "sup", "svg", "table", "tbody", "td", "template", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "track", "u", "ul", "var", "video", "wbr"]

  @valid_childless_tags_string @valid_tags_string -- @valid_open_tags_string

  @valid_tags_atom Enum.reduce(@valid_tags_string, [], fn(tag, acc) ->
    [String.to_atom(tag) | acc]
  end) |> Enum.sort()

  @valid_open_tags_atom Enum.reduce(@valid_open_tags_string, [], fn(tag, acc) ->
    [String.to_atom(tag) | acc]
  end) |> Enum.sort()

  @valid_childless_tags_atom @valid_tags_atom -- @valid_open_tags_atom

  @valid_map Enum.reduce(@valid_tags_string, %{}, fn(tag, acc) ->
    Map.put(acc, tag, String.to_atom(tag))
  end)

  @most_common_tags_string ["div", "p", "a", "img", "button", "h1", "h2", "h3", "h4", "ul", "ol", "li", "input", "br", "hr"]

  @most_common_tags_atom Enum.reduce(@most_common_tags_string, [], fn(tag, acc) ->
    [String.to_atom(tag) | acc]
  end) |> Enum.reverse()

  @without_most_common_string @valid_tags_string -- @most_common_tags_string
  @without_most_common_atom @valid_tags_atom -- @most_common_tags_atom

  def all_tags(:atom), do: @valid_tags_atom
  def all_tags(:string), do: @valid_tags_string
  def childless_tags(:atom), do: @valid_childless_tags_atom
  def childless_tags(:string), do: @valid_childless_tags_string
  def open_tags(:atom), do: @valid_open_tags_atom
  def open_tags(:string), do: @valid_open_tags_string
  def most_common(:atom), do: @most_common_tags_atom
  def most_common(:string), do: @most_common_tags_string
  def without_most_common(:atom), do: @without_most_common_atom
  def without_most_common(:string), do: @without_most_common_string


  def load(data) when is_binary(data) and data in @valid_tags_string, do: {:ok, @valid_map[data]}
  def load(data) when is_atom(data) and data in @valid_tags_atom, do: {:ok, data}
  def load(_), do: :error

  def cast(data) when is_atom(data) and data in @valid_tags_atom, do: {:ok, data}
  def cast(data) when is_binary(data) and data in @valid_tags_string, do: {:ok, @valid_map[data]}
  def cast(_), do: :error

  def dump(data) when is_atom(data) and data in @valid_tags_atom, do: {:ok, Atom.to_string(data)}
  def dump(data) when is_binary(data) and data in @valid_tags_string, do: {:ok, data}
end
