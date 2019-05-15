"use strict";

(function() {

    let proxy_event = "cocktail_click";

    window.cocktail = {
        set_selected: function(id, chain) {
            let prev = this.get_selected();
            this.selected = id;
            this.chain = JSON.parse(chain);
            console.log("set_selected", id);
            return [prev, id];
        },
        get_selected: function() {
            return this.chain.concat(this.selected);
        },
        add_bind: function(el) {
            this.edit_binds = this.edit_binds.concat(el);
        },
        toggle_edit: function() {
            toggle_edit(this.selected);
        },
        get_style: function() {
            let style_prop = document.getElementById("style-prop").value;
            let style_value = document.getElementById("style-prop-value").value;
            return [style_prop, style_value];
        },
        get_classes: function() {
            let class_prop = document.getElementById("class-prop").value;
            return class_prop.split(" ").filter((c) => {
                return c != "cocktail-highlight";
            });
        },
        default_el: "editor-main-body-container",
        selected: "editor-main-body-container",
        chain: [],
        edit_binds: []
    };

    /*bind_edit(window.cocktail, []);
    
    window.addEventListener("click", function(e) {
        window.dispatchEvent(new CustomEvent(proxy_event, {detail: e.target}));
    });

    /*add_proxy_listener(window);

    function add_proxy_listener(obj) {
        obj.addEventListener(proxy_event, function(e) {
            let detail = event.detail;
            let cocktail = detail.getAttribute("cocktail");
            let ct_chain = detail.getAttribute("cocktail-chain");
            console.log(detail, cocktail);
            if (cocktail && ct_chain) {
                obj.cocktail.set_selected(detail.id, ct_chain);
            }
        });
    };
    function bind_edit(obj, binds) {
        var els = document.querySelectorAll("[cocktail-click]");
        els.forEach((el) => {
            obj.add_bind(el);
            el.addEventListener("click", function(e) {
                obj[el.getAttribute("cocktail-click")](); 
            });
        });
    }*/
})();
