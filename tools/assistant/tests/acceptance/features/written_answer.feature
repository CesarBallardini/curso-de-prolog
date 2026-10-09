@bdd
Feature: A written answer from the browser's own language model
  As a student using Chrome with its built-in language model already installed
  I want a short written answer on top of the passages
  So that I understand the passages faster, while the course stays the source

  Rule: the site never downloads a model, and never shows a citation of nothing

  Scenario: The written answer cites the passages it was given, and only those
    Given the browser's own language model is "available" and answers "findall/3 junta todas las soluciones en una lista [1]. Algo que ningún fragmento dice [99]."
    And a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    When the student asks "¿Qué hace findall/3?"
    Then the written answer says "junta todas las soluciones"
    And the written answer does not show "[99]"
    And the citation "[1]" links to a section of "Dónde leerlo"
    And the written answer says it was written by the "modelo del navegador"
    And the passages are still shown
    And the model was asked once, with the question

  Scenario Outline: A model that is not on the device is never downloaded
    Given the browser's own language model is "<availability>" and answers "findall/3 junta todas las soluciones."
    And a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    When the student asks "¿Qué hace findall/3?"
    Then there is no written answer
    And the passages are still shown
    And no model session was created

    Examples:
      | availability |
      | downloadable |
      | downloading  |
      | unavailable  |

  Scenario: A model that fails leaves the passages
    Given the browser's own language model is "available" and fails while answering
    And a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    When the student asks "¿Qué hace findall/3?"
    Then there is no written answer
    And "Dónde leerlo" links to "capitulo-17-todas-las-soluciones/#172-findall3"

  Scenario: Without the Prompt API there is no written answer
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    When the student asks "¿Qué hace findall/3?"
    Then there is no written answer

  Scenario: A question the course does not cover is not given to the model
    Given the browser's own language model is "available" and answers "Una receta."
    And a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    When the student asks "¿Cómo se prepara una pizza napolitana?"
    Then no model session was created

  Scenario: Each question gets its own session, and the session is closed
    Given the browser's own language model is "available" and answers "findall/3 junta todas las soluciones [1]."
    And a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    When the student asks "¿Qué hace findall/3?"
    And the student asks "¿Qué hace bagof/3?"
    Then 2 model sessions were created and 2 were closed
