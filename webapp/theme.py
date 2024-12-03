

import reflex as rx

def std_theme() -> rx.Component:
    return rx.theme(
        appearance="light",
        accent_color="orange",
        panel_background="solid",
        radius="large",
        scaling="100%"
    )