@bdd
Feature: Loading the course into the panel
  As a student on a slow or unreliable connection
  I want the page to load as fast as without the panel, and to be told when the panel cannot work
  So that the course is never slower or broken because of it

  Scenario Outline: The launcher is on every kind of page
    Given a student reading the page "<page>"
    Then the button "Preguntar al curso" is visible

    Examples:
      | page                                              |
      | home                                              |
      | capitulo-07-listas/                               |
      | patrones/                                         |
      | capitulo-87-proyecto-preguntas-en-castellano/     |

  Scenario: The course is downloaded when the panel opens, not before
    Given a student reading the page "capitulo-07-listas/"
    When the page has finished loading
    Then the course's index has been requested 0 times
    When the student opens the panel and asks "¿Qué hace findall/3?"
    Then the course's index has been requested 1 time

  Scenario: A question asked while the course is loading is answered when it arrives
    Given a student reading the page "capitulo-07-listas/"
    And the course's index is slow to arrive
    When the student opens the panel and sends "¿Qué hace findall/3?"
    Then the panel says "Cargando el curso…"
    When the course's index arrives
    Then "Dónde leerlo" links to "capitulo-17-todas-las-soluciones/#172-findall3"

  Scenario: The panel says so when the course cannot be loaded
    Given a student reading the page "capitulo-07-listas/"
    And the course's index cannot be downloaded
    When the student has opened the panel
    Then the panel says "No se pudo cargar el curso"

  Scenario: The panel says so when the search itself cannot start
    Given a student reading the page "capitulo-07-listas/"
    And the search worker cannot be downloaded
    When the student opens the panel and sends "¿Qué hace findall/3?"
    Then the panel says "No se pudo cargar el curso"
    And the answer says "No se pudo responder esta pregunta"

  Scenario: An index of another version is refused
    Given a student reading the page "capitulo-07-listas/"
    And the course's index is of version 2
    When the student has opened the panel
    Then the panel says "No se pudo cargar el curso"
