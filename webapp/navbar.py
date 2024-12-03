import reflex as rx

def navbar_link(text: str, url: str) -> rx.Component:
    return rx.link(
            rx.button(
                rx.hstack(
                    rx.text(text, size="3", weight="medium"),
                ),
            variant="ghost",
            padding="0.5em 1em",
            border_radius="md",
            ),
        href=url
        )


def navbar() -> rx.Component:
    return rx.box(
        rx.desktop_only(
            rx.hstack(
                rx.hstack(
                    rx.link(
                        rx.image(
                            src="/dcrenlogo.png",
                            width="auto",
                            height="3em",
                            border_radius="25%",
                        ),
                        href="/",
                        underline="none",
                    ),
                    rx.heading(
                        "DC Ren platform", size="6", weight="bold"
                    ),
                    align_items="center",
                ),
                rx.box(
                    width = "5%"
                ),
                rx.hstack(
                    navbar_link("Predictions", "/predictions"),
                    navbar_link("Results", "/results"),
                    navbar_link("Training", "/training"),
                    spacing="6",
                ),
                rx.spacer(),
                rx.menu.root(
                    rx.menu.trigger(
                        rx.icon_button(
                            rx.icon("user"),
                            size="2",
                            radius="full",
                        )
                    ),
                    rx.menu.content(
                        rx.menu.item("Profile"),
                        rx.menu.separator(),
                        rx.menu.item("Log out"),
                    ),
                    justify="end",
                ),
                justify="between",
                align_items="center",
            ),
        ),
        rx.mobile_and_tablet(
            rx.hstack(
                rx.link(
                    rx.hstack(
                        rx.image(
                            src="/logo.jpg",
                            width="2em",
                            height="auto",
                            border_radius="25%",
                        ),
                        rx.heading(
                            "Reflex", size="6", weight="bold"
                        ),
                        align_items="center",
                    ),
                    href="/",
                ),
                rx.menu.root(
                    rx.menu.trigger(
                        rx.icon_button(
                            rx.icon("user"),
                            size="2",
                            radius="full",
                        )
                    ),
                    rx.menu.content(
                        rx.menu.item("Settings"),
                        rx.menu.item("Earnings"),
                        rx.menu.separator(),
                        rx.menu.item("Log out"),
                    ),
                    justify="end",
                ),
                justify="between",
                align_items="center",
            ),
        ),
        bg=rx.color("accent", 3),
        padding="1em",
        # position="fixed",
        # top="0px",
        # z_index="5",
        width="100%",
    )