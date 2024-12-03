import reflex as rx
from webapp.components.dynoselect import dynoselect

class Buttone(rx.ComponentState):

    var: str
    mappa: str

    def set_var(self, var):
        self.var = var

    def set_map(self, mappa):
        self.mappa = mappa

    @classmethod
    def get_component(self, **props):
        self.var = props.pop("variable")
        return rx.hstack(
                rx.button(
                        rx.text(f"{self.var} = {self.mappa}", align='right'),
                        width="60%", variant="outline", color_scheme="iris"
                        ),
                    rx.icon("arrow-right-from-line"),
                    rx.select(
                        ["we", "mba", "re"],
                        width="40%",
                        on_change=lambda x: self.set_map(x)
                        )
                    # rx.input(
                    #     placeholder="Inserisci valore", 
                    #     width="40%",
                    #     on_blur=lambda x: self.set_map(x)
                    #     )
        )



   
   
def dyno_select(choices, state):
        return rx.select.root(
                    rx.select.trigger(placeholder="Select variable"),
                    rx.select.content(
                        rx.select.group(
                            rx.select.label(
                                rx.box(
                                    rx.input(
                                        placeholder="Search variable", 
                                        on_change=lambda x: state.set_search(x)
                                    ),
                                ),
                            ),  
                        ),
                        rx.select.separator(),
                        rx.select.group(
                            rx.foreach(
                                choices,
                                lambda choice: rx.select.item(
                                                    rx.tooltip(
                                                        rx.text(
                                                            choice, 
                                                            size="5"),
                                                        content="description",
                                                        aria_label=True,
                                                        ),
                                                value=choice),
                            ),
                            spacing="3",
                        ),
                    ),
                )




               