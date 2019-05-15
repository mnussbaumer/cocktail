defmodule Personal.DefaultComponents do

  @default_page %{
    attrs: [],
    body: [
      %Cocktail.Element{
        attrs: [],
        body: [
          %Cocktail.Element{
            attrs: [],
            body: [],
            classes: ["flex-column", "align-items-center",
                      "justify-content-center"], 
            content: "Magic Mushrooms",
            id: "8233846224AB",
            interactions: [],
            style: [
              {"font-weight", "800"},
              {"color", "white"},
              {"background-color", "rgb(175,175,175)"},
              {"height", "200px"}
            ],
            tag: :div
},
          %Cocktail.Element{
            attrs: [],
            body: [
              %Cocktail.Element{
                attrs: [],
                body: [],
                classes: [],
                content: "And other stuff",
                id: "441D3726ABA0",
                interactions: [],
                style: [],
                tag: :p
}
            ],
            classes: ["flex-column", "align-items-center",
                      "justify-content-center"],
            content: "",
            id: "8D78A96AFCEF",
            interactions: [],
            style: [
              {"color", "white !important"},
              {"font-weight", "800"},
              {"background-color", "rgb(175,175,175)"},
              {"height", "200px"}
            ],
            tag: :div
          },
          %Cocktail.Element{
            attrs: [],
            body: [
              %Cocktail.Element{
                attrs: [],
                body: [],
                classes: [],
                content: "And some other div",
                id: "FB27A76CAF0A",
                interactions: [],
                style: [{"margin-top", "25px"}],
                tag: :div
}
            ],
            classes: ["flex-column", "align-items-center",
                      "justify-content-center"],
            content: "Some other column",
            id: "FA0D76486522",
            interactions: [],
            style: [
              {"font-weight", "800"},
              {"color", "white"},
              {"background-color", "rgb(175,175,175)"},
              {"height", "200px"}
            ],
            tag: :div
          }
        ],
        classes: ["children-flex-1-0", "flex-row"],
        content: nil,
        id: "39D094B34B6D",
        interactions: [],
        style: [],
        tag: :div
},
      %Cocktail.Element{
        attrs: [],
        body: [],
        classes: ["m-5"],
        content: "Be careful, magic mushrooms led Alice down the rabbit hole",
        id: "EF36638853A4",
        interactions: [],
        style: [
          {"color", "rgb(175,175,175)"},
          {"font-weight", "bold"},
          {"font-size", "36px"},
          {"text-align", "center"}
        ],
        tag: :div
      }
    ],
    classes: [],
    components: [["component-AE8289F59755", "default-3-column"]],
    created_at: DateTime.utc_now(),
    id: "1A5FA1337B87",
    interactions: [],
    javascripts: [],
    protected: true,
    published: true,
    published_at: DateTime.utc_now(),
    saved: true,
    selected: %{
      attrs: [],
      classes: [],
      components: [["component-AE8289F59755", "default-3-column"]],
      created_at: DateTime.utc_now(),
      full_chain: ["editor-main-body-container"],
      id: "1A5FA1337B87",
      interactions: [],
      javascripts: [],
      next_sib: false,
      previous_sib: false,
      protected: false,
      published: false,
      published_at: nil,
      saved: true,
      selected: %{
        attrs: [],
        classes: ["flex-column", "align-items-center", "justify-content-center"],
        content: "",
        full_chain: ["editor-main-body-container", "39D094B34B6D",
                     "8D78A96AFCEF"],
        id: "8D78A96AFCEF",
        interactions: [],
        next_sib: "FA0D76486522",
        previous_sib: "8233846224AB",
        style: [
          {"color", "white !important"},
          {"font-weight", "800"},
          {"background-color", "rgb(175,175,175)"},
          {"height", "200px"}
        ],
        tag: :div,
        title: false
      },
      show_components: false,
      show_edit_menu: false,
      show_global_options: false,
      show_page_options: false,
      slug: "example-page",
      style: [],
      stylesheets: [],
      title: "example",
      type: :page,
      updated_at: DateTime.utc_now()
    },
    show_components: false,
    show_edit_menu: false,
    show_global_options: false,
    show_page_options: false,
    slug: "example-page",
    style: [],
    stylesheets: [],
    title: "example",
    type: :page,
    updated_at: DateTime.utc_now()
  }

  @default_components [
    %{
      attrs: [],
      body: [
        %Cocktail.Element{
          attrs: [],
          body: [],
          classes: ["flex-column", "align-items-center", "justify-content-center"],
          content: "First Column",
          id: "E224AF953D9B",
          interactions: [],
          style: [
            {"font-weight", "800"},
            {"color", "white"},
            {"background-color", "rgb(175,175,175)"},
            {"height", "200px"}
          ],
          tag: :div
},
        %Cocktail.Element{
          attrs: [],
          body: [],
          classes: ["flex-column", "align-items-center", "justify-content-center"],
          content: "Second Column",
          id: "69037139C291",
          interactions: [],
          style: [
            {"font-weight", "800"},
            {"color", "white"},
            {"background-color", "rgb(175,175,175)"},
            {"height", "200px"}
          ],
          tag: :div
        },
        %Cocktail.Element{
          attrs: [],
          body: [],
          classes: ["flex-column", "align-items-center", "justify-content-center"],
          content: "Third Column",
          id: "CC7D5A9949DE",
          interactions: [],
          style: [
            {"font-weight", "800"},
            {"color", "white"},
            {"background-color", "rgb(175,175,175)"},
            {"height", "200px"}
          ],
          tag: :div
        }
      ],
      classes: ["children-flex-1-0", "flex-row"],
      components: [],
      created_at: DateTime.utc_now(),
      id: "component-AE8289F59755",
      interactions: [],
      javascripts: [],
      protected: true,
      published: nil,
      published_at: nil,
      saved: false,
      selected: %{
        attrs: [],
        classes: ["flex-column", "align-items-center", "justify-content-center"],
        content: "New Element - CC7D5A9949DE",
        full_chain: ["editor-main-body-container", "CC7D5A9949DE"],
        id: "CC7D5A9949DE",
        interactions: [],
        next_sib: false,
        previous_sib: "69037139C291",
        style: [
          {"font-weight", "800"},
          {"color", "white"},
          {"background-color", "rgb(175,175,175)"}, 
          {"height", "200px"}
        ],
        tag: :div,
        title: false
      },
      show_components: false,
      show_edit_menu: false,
      show_global_options: false,
      show_page_options: false,
      slug: "component-AE8289F59755",
      style: [],
      stylesheets: [],
      title: "default-3-column",
      type: :component,
      updated_at: DateTime.utc_now()
    }
  ]

  def default(persister_mod, state) do
    Enum.each(@default_components ++ [@default_page], fn(component) ->
      persister_mod.publish(component, state)
    end)
  end
end
