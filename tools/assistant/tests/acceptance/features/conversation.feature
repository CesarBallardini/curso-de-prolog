@bdd
Feature: The conversation follows the student through the course
  As a student who follows the links the panel gives
  I want my earlier questions and answers to stay in the panel
  So that I can go back to them from the section I am reading

  Scenario: Moving to another page keeps the conversation and the downloaded course
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    And the student has asked "¿Qué hace findall/3?"
    When the student closes the panel
    And the student goes to the chapter "Backtracking y corte" from the navigation
    And the student has opened the panel
    Then the conversation has 1 exchange
    When the student asks "¿Qué es el corte rojo?"
    Then the course's index has been requested 1 time

  Scenario: Reloading the page keeps the conversation
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    And the student has asked "¿Qué hace findall/3?"
    When the student reloads the page
    And the student has opened the panel
    Then the conversation has 1 exchange
    And the first exchange mentions "findall/3"

  Scenario: One question can be removed, and stays removed
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    And the student has asked "¿Qué hace findall/3?"
    And the student has asked "¿Qué es el corte rojo?"
    When the student removes the question "¿Qué hace findall/3?"
    Then the conversation has 1 exchange
    And the first exchange mentions "corte rojo"
    When the student reloads the page
    And the student has opened the panel
    Then the conversation has 1 exchange

  Scenario: The whole conversation can be cleared
    Given a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    And the student has asked "¿Qué hace findall/3?"
    And the student has asked "¿Qué es el corte rojo?"
    When the student presses the button "Borrar la conversación"
    Then the conversation is empty
    When the student reloads the page
    And the student has opened the panel
    Then the conversation is empty

  Scenario: Reloading the page keeps a written answer
    Given the browser's own language model is "available" and answers "findall/3 junta todas las soluciones en una lista [1]."
    And a student reading the page "capitulo-07-listas/"
    And the student has opened the panel
    And the student has asked "¿Qué hace findall/3?"
    And the written answer says "junta todas las soluciones"
    When the student reloads the page
    And the student has opened the panel
    Then the written answer says "junta todas las soluciones"
