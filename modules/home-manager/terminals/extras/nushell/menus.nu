let menus = [
        {
            name: zoxide_menu
            only_buffer_difference: true
            marker: "| "
            type: {
                layout: columnar
                page_size: 20
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
            source: { |buffer, position|
                zoxide query -ls $buffer
                | parse -r '(?P<description>[0-9]+) (?P<value>.+)'
            }
        }
    ]

