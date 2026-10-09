@bdd
Feature: Asking the course a question
  As a student of the Prolog course
  I want to ask a question in my own words
  So that I am sent to the sections of the course that answer it

  Background:
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel

  Scenario Outline: A question finds the section that answers it
    When the student asks "<question>"
    Then "Dónde leerlo" links to "<section>"

    Examples:
      | question                                                 | section                                                        |
      | ¿Qué hace findall/3?                                     | capitulo-17-todas-las-soluciones/#172-findall3                 |
      | ¿Cuál es la diferencia entre corte verde y corte rojo?   | capitulo-09-backtracking-y-corte/#95-corte-verde-y-corte-rojo  |

  Scenario: An operator is searched as it is written
    When the student asks "¿Qué significa \+ en una regla?"
    Then "Dónde leerlo" links to a section of the page "capitulo-10-negacion-como-falla/"

  Scenario: Accents do not matter
    When the student asks "¿Qué es la negación como falla?"
    And the student asks "que es la negacion como falla"
    Then both answers list the same sections
    And "Dónde leerlo" links to a section of the page "capitulo-10-negacion-como-falla/"

  Scenario: The sections are listed in the order of the course
    When the student asks "¿Cómo se recorre una lista con recursión?"
    Then the sections of "Dónde leerlo" are in the order of the course
    And the passages follow the order of "Dónde leerlo"

  Scenario: An answer shows where to read and what the course says
    When the student asks "¿Qué hace findall/3?"
    Then "Dónde leerlo" lists between 1 and 5 different sections
    And between 1 and 3 passages are shown, each with one link to a section of that list
    And "findall" is highlighted in a passage

  Scenario Outline: A solutions page is never linked
    When the student asks "<question>"
    Then no link leads to a solutions page

    Examples:
      | question                                                 |
      | soluciones del capítulo 10                               |
      | solución del ejercicio 7.1                               |
      | ¿Cuál es la respuesta del ejercicio de append/3?         |

  Scenario: A question the course does not cover is said so
    When the student asks "¿Cómo se prepara una pizza napolitana?"
    Then the answer says "no parece tratar"

  Scenario: A blank question is not asked
    When the student sends a question made of spaces
    Then the conversation is empty

  Scenario: Enter asks the question
    When the student types "¿Qué hace findall/3?" and presses Enter
    Then the conversation has 1 exchange

  Scenario: A link leads to its section and closes the panel
    When the student asks "¿Qué hace findall/3?"
    And the student follows the link of section "17.2"
    Then the browser shows "capitulo-17-todas-las-soluciones/#172-findall3"
    And the heading "172-findall3" is in view
    And the panel is closed
