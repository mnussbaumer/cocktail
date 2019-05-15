export function transform_panel(live, type, el, phxEvent, val) {
    console.log("transform_panel", el, phxEvent, type);
    switch (phxEvent) {
    /*case "add_div":
        val = {id: window.cocktail.get_selected(), add: "div"};
        break;
    case "delete_element":
        val = {id: window.cocktail.get_selected()};
        break;
    case "add_style":
        val = {id: window.cocktail.get_selected(), ...window.cocktail.get_style()};
        break;
    case "toggle_edit":
        val = {id: window.cocktail.get_selected()};
        break;
    */
    case "add_element":
        var selected = document.getElementById("add_element_select").value;
        val = selected;
        break;
    case "select":
        console.log("transform select", el);
        var chain = JSON.parse(el.getAttribute("cocktail-chain"));
        var id = el.id;
        val = chain.concat(id);
        break;
    case "update_style":
        var input_el = document.getElementById(el.getAttribute("cocktail-ref"));
        var style = input_el.id.replace(/^style-/, "");
        var value = input_el.value;
        val = [style, value];
        phxEvent = "add_style";
        break;
    case "add_style":
        val = window.cocktail.get_style();
        break;
    case "add_style_children":
        val = window.cocktail.get_style();
        break;
    case "delete_style":
        val = JSON.parse(val);
        break;
    case "add_class":
        val = window.cocktail.get_classes();
        break;
    case "add_class_children":
        val = window.cocktail.get_classes();
        break;
    case "page_settings":
        var ref = el.getAttribute("cocktail-ref");
        var input_el = document.getElementById(ref);
        val = {what: input_el.getAttribute("cocktail-target"), val: input_el.value};
        break;
    case "update_content":
        var content = document.getElementById("content-content");
        var radios = document.getElementsByName("content-type");
        for (var i = 0, length = radios.length; i < length; i++) {
            if (radios[i].checked) {
                val = {content: content.value, type: radios[i].value};
                break;
            }
        }
        break;
    default:
        null;
        break;
    }
    return {
        type: type,
        event: phxEvent,
        value: val
    }
}

export function on_update() {
    if (window.cocktail) {
        //window.cocktail.highlight_selected();
    }
}
