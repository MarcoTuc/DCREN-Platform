import reflex as rx

class SpeedDialVerticalText(rx.ComponentState):
    is_open: bool = False

    def toggle(self, value: bool):
        self.is_open = value

    @classmethod
    def get_component(cls, **props):
        def menu_item(icon: str, text: str) -> rx.Component:
            return rx.hstack(
                rx.text(text, weight="medium"),
                rx.icon_button(
                    rx.icon(icon, padding="2px"),
                    variant="soft",
                    color_scheme="gray",
                    size="3",
                    cursor="pointer",
                    radius="full",
                    position="relative",
                ),
                opacity="0.75",
                _hover={
                    "opacity": "1",
                },
                align_items="center",
            )

        def menu() -> rx.Component:
            return rx.vstack(
                menu_item("copy", "Copy"),
                menu_item("download", "Download"),
                menu_item("share-2", "Share"),
                position="absolute",
                bottom="100%",
                spacing="2",
                padding_bottom="10px",
                right="0",
                direction="column-reverse",
                align_items="end",
                justify_content="end",
            )

        return rx.box(
            rx.box(
                rx.icon_button(
                    rx.icon(
                        "plus",
                        style={
                            "transform": rx.cond(
                                cls.is_open,
                                "rotate(45deg)",
                                "rotate(0)",
                            ),
                            "transition": "transform 150ms cubic-bezier(0.4, 0, 0.2, 1)",
                        },
                        class_name="dial",
                    ),
                    variant="solid",
                    color_scheme="crimson",
                    size="3",
                    cursor="pointer",
                    radius="full",
                    position="relative",
                ),
                rx.cond(
                    cls.is_open,
                    menu(),
                ),
                position="relative",
            ),
            on_mouse_enter=cls.toggle(True),
            on_mouse_leave=cls.toggle(False),
            on_click=cls.toggle(~cls.is_open),
            style={"bottom": "15px", "right": "15px"},
            position="absolute",
            # z_index="50",
            **props,
        )


speed_dial_vertical_text = SpeedDialVerticalText.create


def render_vertical_text():
    return rx.box(
        speed_dial_vertical_text(),
        height="250px",
        position="relative",
        width="100%",
    )