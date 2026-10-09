@bdd
Feature: The panel works with the keyboard, on a phone and in both colour schemes
  As a student who uses the keyboard, a phone or the dark scheme
  I want the panel to work as well as the rest of the site
  So that it is not harder to use than the course itself

  Scenario: Escape closes the panel and gives the focus back to the button
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    Then the question box has the focus
    When the student presses "Escape"
    Then the panel is closed
    And the button "Preguntar al curso" has the focus

  Scenario: The close button gives the focus back to the button
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    When the student presses the button "Cerrar"
    Then the panel is closed
    And the button "Preguntar al curso" has the focus

  Scenario Outline: The focus stays in the panel
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    And the student has asked "¿Qué hace findall/3?"
    When the student presses "<key>" 25 times
    Then the focus never left the panel

    Examples:
      | key       |
      | Tab       |
      | Shift+Tab |

  Scenario: On a phone the panel takes the whole screen
    Given a student reading the page "capitulo-07-listas/" on a phone
    And the student has opened the panel
    Then the panel covers the screen

  Scenario: On a phone the button does not cover the back-to-top button
    Given a student reading the page "capitulo-07-listas/" on a phone
    When the student scrolls down and back up a little
    Then the back-to-top button is visible
    And the button "Preguntar al curso" does not overlap it

  Scenario: The panel follows the system's colour scheme
    Given a student whose system prefers the "light" scheme, reading the page "capitulo-07-listas/"
    And the student has opened the panel
    Then the panel is light
    Given a student whose system prefers the "dark" scheme, reading the page "capitulo-07-listas/"
    And the student has opened the panel
    Then the panel is dark

  Scenario: The panel follows the site's own colour switch
    Given a student whose system prefers the "light" scheme, reading the page "capitulo-07-listas/"
    When the student switches the site to "Modo oscuro"
    And the student has opened the panel
    Then the panel is dark
