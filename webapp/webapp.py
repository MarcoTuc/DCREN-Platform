from rxconfig import config

import reflex as rx

from webapp.style import style
from webapp.theme import std_theme
from webapp.navbar import navbar

from webapp.pages.experiments import experiments
from webapp.pages.predictions import predictions
from webapp.pages.training import training

class AppState(rx.State):
    """The app state."""


def index() -> rx.Component:
    return rx.box(
            navbar(),
            rx.center(
                rx.vstack(
                    rx.heading("Welcome to the DC-REN platform", size="7", padding_top="8em"),
                    rx.image(
                            src="dcrenlogo.png",
                            width="auto",
                            height="10em",
                            border_radius="25%",
                        ),
                    align="center",
                    spacing="2em",
                ),
            ),
        )

# ------------ Define the app 
app = rx.App(
    theme=std_theme(),
    # style=style
)

# ------------ Add pages to the app
app.add_page(index)
app.add_page(predictions, route="/predictions")
app.add_page(training, route="/training")
app.add_page(experiments, route="/results")
