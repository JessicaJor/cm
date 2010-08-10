!> \file
!> $Id: fluid_mechanics_routines.f90 177 2009-04-20 
!> \author Sebastian Krittian
!> \brief This module handles all fluid mechanics routines.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> This module handles all fluid mechanics class routines.
MODULE FLUID_MECHANICS_ROUTINES

  USE BASE_ROUTINES
  USE CONTROL_LOOP_ROUTINES
  USE DARCY_EQUATIONS_ROUTINES
  USE EQUATIONS_SET_CONSTANTS
  USE INPUT_OUTPUT
  USE ISO_VARYING_STRING
  USE KINDS
  USE STOKES_EQUATIONS_ROUTINES
  USE NAVIER_STOKES_EQUATIONS_ROUTINES
  USE PROBLEM_CONSTANTS
  USE STRINGS
  USE TYPES


  IMPLICIT NONE

  PRIVATE

  !Module parameters

  !Module types

  !Module variables

  !Interfaces

  PUBLIC FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_GET,FLUID_MECHANICS_PROBLEM_CLASS_TYPE_GET

  PUBLIC FLUID_MECHANICS_FINITE_ELEMENT_JACOBIAN_EVALUATE,FLUID_MECHANICS_FINITE_ELEMENT_RESIDUAL_EVALUATE

  PUBLIC FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_SET,FLUID_MECHANICS_FINITE_ELEMENT_CALCULATE, &
    & FLUID_MECHANICS_EQUATIONS_SET_SETUP,FLUID_MECHANICS_EQUATIONS_SET_SOLUTION_METHOD_SET, &
    & FLUID_MECHANICS_PROBLEM_CLASS_TYPE_SET,FLUID_MECHANICS_PROBLEM_SETUP, &
    & FLUID_MECHANICS_POST_SOLVE,FLUID_MECHANICS_PRE_SOLVE,FLUID_MECHANICS_CONTROL_LOOP_PRE_LOOP, &
    & FLUID_MECHANICS_CONTROL_LOOP_POST_LOOP

CONTAINS

  !
  !================================================================================================================================
  !

  !>Gets the problem type and subtype for a fluid mechanics equation set class.
  SUBROUTINE FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_GET(EQUATIONS_SET,EQUATIONS_TYPE,EQUATIONS_SUBTYPE, &
    & ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    INTEGER(INTG), INTENT(OUT) :: EQUATIONS_TYPE !<On return, the equation type
    INTEGER(INTG), INTENT(OUT) :: EQUATIONS_SUBTYPE !<On return, the equation subtype
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    
    CALL ENTERS("FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      IF(EQUATIONS_SET%CLASS==EQUATIONS_SET_FLUID_MECHANICS_CLASS) THEN
        EQUATIONS_TYPE=EQUATIONS_SET%TYPE
        EQUATIONS_SUBTYPE=EQUATIONS_SET%SUBTYPE
      ELSE
        CALL FLAG_ERROR("Equations set is not the fluid mechanics type",ERR,ERROR,*999)
      END IF
    ELSE
      CALL FLAG_ERROR("Equations set is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_GET")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_GET",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_GET")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_GET

  !
  !================================================================================================================================
  !

  !>Sets/changes the problem type and subtype for a fluid mechanics equation set class.
  SUBROUTINE FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_SET(EQUATIONS_SET,EQUATIONS_TYPE,EQUATIONS_SUBTYPE, &
    & ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    INTEGER(INTG), INTENT(IN) :: EQUATIONS_TYPE !<The equation type
    INTEGER(INTG), INTENT(IN) :: EQUATIONS_SUBTYPE !<The equation subtype
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_EQUATIONS_SET_CLASS_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_TYPE)
      CASE(EQUATIONS_SET_STOKES_EQUATION_TYPE)
        CALL STOKES_EQUATIONS_SET_SUBTYPE_SET(EQUATIONS_SET,EQUATIONS_SUBTYPE,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET(EQUATIONS_SET,EQUATIONS_SUBTYPE,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_DARCY_EQUATION_TYPE)
        CALL DARCY_EQUATION_EQUATIONS_SET_SUBTYPE_SET(EQUATIONS_SET,EQUATIONS_SUBTYPE,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set equation type "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics equations set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_SET")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_SET",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_SET")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_EQUATIONS_SET_CLASS_TYPE_SET

  !
  !================================================================================================================================
  !

  !>Calculates the element stiffness matries and rhs vector for the given element number for a fluid mechanics class finite element equation set.
  SUBROUTINE FLUID_MECHANICS_FINITE_ELEMENT_CALCULATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to calcualate
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_FINITE_ELEMENT_CALCULATE",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%TYPE)
      CASE(EQUATIONS_SET_STOKES_EQUATION_TYPE)
        CALL STOKES_FINITE_ELEMENT_CALCULATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE)
        CALL FLAG_ERROR("There is no element stiffness matrix to be calculated for Navier-Stokes.",ERR,ERROR,*999)
      CASE(EQUATIONS_SET_DARCY_EQUATION_TYPE)
        CALL DARCY_EQUATION_FINITE_ELEMENT_CALCULATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set type "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics equation set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_FINITE_ELEMENT_CALCULATE")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_FINITE_ELEMENT_CALCULATE",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_FINITE_ELEMENT_CALCULATE")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_FINITE_ELEMENT_CALCULATE

  !
  !================================================================================================================================
  !

  !>Evaluates the element Jacobian matrix for the given element number for a fluid mechanics class finite element equation set.
  SUBROUTINE FLUID_MECHANICS_FINITE_ELEMENT_JACOBIAN_EVALUATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to evaluate the Jacobian for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_FINITE_ELEMENT_JACOBIAN_EVALUATE",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%TYPE)
      CASE(EQUATIONS_SET_STOKES_EQUATION_TYPE)
        CALL FLAG_ERROR("There is no Jacobian to be evaluated for Stokes.",ERR,ERROR,*999)
      CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_DARCY_EQUATION_TYPE)
        CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set type "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics equation set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_FINITE_ELEMENT_JACOBIAN_EVALUATE")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_FINITE_ELEMENT_JACOBIAN_EVALUATE",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_FINITE_ELEMENT_JACOBIAN_EVALUATE")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_FINITE_ELEMENT_JACOBIAN_EVALUATE

  !
  !================================================================================================================================
  !

  !>Evaluates the element residual and rhs vectors for the given element number for a fluid mechanics class finite element equation set.
  SUBROUTINE FLUID_MECHANICS_FINITE_ELEMENT_RESIDUAL_EVALUATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_FINITE_ELEMENT_RESIDUAL_EVALUATE",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%TYPE)
      CASE(EQUATIONS_SET_STOKES_EQUATION_TYPE)
        CALL FLAG_ERROR("There is no residual to be evaluated for Stokes.",ERR,ERROR,*999)
      CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_DARCY_EQUATION_TYPE)
        CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set type "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics equation set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_FINITE_ELEMENT_RESIDUAL_EVALUATE")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_FINITE_ELEMENT_RESIDUAL_EVALUATE",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_FINITE_ELEMENT_RESIDUAL_EVALUATE")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_FINITE_ELEMENT_RESIDUAL_EVALUATE

  !
  !================================================================================================================================
  !

  !>Sets up the equations set for a fluid mechanics equations set class.
  SUBROUTINE FLUID_MECHANICS_EQUATIONS_SET_SETUP(EQUATIONS_SET,EQUATIONS_SET_SETUP,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(EQUATIONS_SET_SETUP_TYPE), INTENT(INOUT) :: EQUATIONS_SET_SETUP !<The equations set setup information
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_EQUATIONS_SET_SETUP",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%TYPE)
      CASE(EQUATIONS_SET_STOKES_EQUATION_TYPE)
        CALL STOKES_EQUATIONS_SET_SETUP(EQUATIONS_SET,EQUATIONS_SET_SETUP,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_EQUATIONS_SET_SETUP(EQUATIONS_SET,EQUATIONS_SET_SETUP,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_DARCY_EQUATION_TYPE)
        CALL DARCY_EQUATION_EQUATIONS_SET_SETUP(EQUATIONS_SET,EQUATIONS_SET_SETUP,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equation set type "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics equation set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_EQUATIONS_SET_SETUP")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_EQUATIONS_SET_SETUP",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_EQUATIONS_SET_SETUP")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_EQUATIONS_SET_SETUP
  

  !
  !================================================================================================================================
  !

  !>Sets/changes the solution method for a fluid mechanics equation set class.
  SUBROUTINE FLUID_MECHANICS_EQUATIONS_SET_SOLUTION_METHOD_SET(EQUATIONS_SET,SOLUTION_METHOD,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to set the solution method for
    INTEGER(INTG), INTENT(IN) :: SOLUTION_METHOD !<The solution method to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_EQUATIONS_SOLUTION_METHOD_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%TYPE)
      CASE(EQUATIONS_SET_STOKES_EQUATION_TYPE)
        CALL STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET(EQUATIONS_SET,SOLUTION_METHOD,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET(EQUATIONS_SET,SOLUTION_METHOD,ERR,ERROR,*999)
      CASE(EQUATIONS_SET_DARCY_EQUATION_TYPE)
        CALL DARCY_EQUATION_EQUATIONS_SET_SOLUTION_METHOD_SET(EQUATIONS_SET,SOLUTION_METHOD,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set equation type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechancis equations set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_EQUATIONS_SET_SOLUTION_METHOD_SET")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_EQUATIONS_SET_SOLUTION_METHOD_SET",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_EQUATIONS_SET_SOLUTION_METHOD_SET")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_EQUATIONS_SET_SOLUTION_METHOD_SET

  !
  !================================================================================================================================
  !

  !>Gets the problem type and subtype for a fluid mechanics problem class.
  SUBROUTINE FLUID_MECHANICS_PROBLEM_CLASS_TYPE_GET(PROBLEM,PROBLEM_EQUATION_TYPE,PROBLEM_SUBTYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem
    INTEGER(INTG), INTENT(OUT) :: PROBLEM_EQUATION_TYPE !<On return, the problem type
    INTEGER(INTG), INTENT(OUT) :: PROBLEM_SUBTYPE !<On return, the proboem subtype
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    
    CALL ENTERS("FLUID_MECHANICS_PROBLEM_CLASS_TYPE_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      IF(PROBLEM%CLASS==PROBLEM_FLUID_MECHANICS_CLASS) THEN
        PROBLEM_EQUATION_TYPE=PROBLEM%TYPE
        PROBLEM_SUBTYPE=PROBLEM%SUBTYPE
      ELSE
        CALL FLAG_ERROR("Problem is not fluid mechanics class",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Problem is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_PROBLEM_CLASS_TYPE_GET")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_PROBLEM_CLASS_TYPE_GET",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_PROBLEM_CLASS_TYPE_GET")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_PROBLEM_CLASS_TYPE_GET

  !
  !================================================================================================================================
  !

  !>Sets/changes the problem type and subtype for a fluid mechanics problem class.
  SUBROUTINE FLUID_MECHANICS_PROBLEM_CLASS_TYPE_SET(PROBLEM,PROBLEM_EQUATION_TYPE,PROBLEM_SUBTYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem
    INTEGER(INTG), INTENT(IN) :: PROBLEM_EQUATION_TYPE !<The problem type
    INTEGER(INTG), INTENT(IN) :: PROBLEM_SUBTYPE !<The proboem subtype
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_PROBLEM_CLASS_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      SELECT CASE(PROBLEM_EQUATION_TYPE)
      CASE(PROBLEM_STOKES_EQUATION_TYPE)
        CALL STOKES_PROBLEM_SUBTYPE_SET(PROBLEM,PROBLEM_SUBTYPE,ERR,ERROR,*999)
      CASE(PROBLEM_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_PROBLEM_SUBTYPE_SET(PROBLEM,PROBLEM_SUBTYPE,ERR,ERROR,*999)
      CASE(PROBLEM_DARCY_EQUATION_TYPE)
        CALL DARCY_EQUATION_PROBLEM_SUBTYPE_SET(PROBLEM,PROBLEM_SUBTYPE,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Problem equation type "//TRIM(NUMBER_TO_VSTRING(PROBLEM_EQUATION_TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics problem class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_PROBLEM_CLASS_TYPE_SET")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_PROBLEM_CLASS_TYPE_SET",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_PROBLEM_CLASS_TYPE_SET")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_PROBLEM_CLASS_TYPE_SET

  !
  !================================================================================================================================
  !

  !>Sets up the problem for a fluid mechanics problem class.
  SUBROUTINE FLUID_MECHANICS_PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem
    TYPE(PROBLEM_SETUP_TYPE), INTENT(INOUT) :: PROBLEM_SETUP !<The problem setup information
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_PROBLEM_SETUP",ERR,ERROR,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      SELECT CASE(PROBLEM%TYPE)
      CASE(PROBLEM_STOKES_EQUATION_TYPE)
        CALL STOKES_PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP,ERR,ERROR,*999)
      CASE(PROBLEM_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP,ERR,ERROR,*999)
      CASE(PROBLEM_DARCY_EQUATION_TYPE)
        CALL DARCY_EQUATION_PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Problem type "//TRIM(NUMBER_TO_VSTRING(PROBLEM%TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics problem class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_PROBLEM_SETUP")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_PROBLEM_SETUP",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_PROBLEM_SETUP")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_PROBLEM_SETUP

  !
  !================================================================================================================================
  !

  !>Sets up the output type for a fluid mechanics problem class.
  SUBROUTINE FLUID_MECHANICS_POST_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_POST_SOLVE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
      SELECT CASE(CONTROL_LOOP%PROBLEM%TYPE)
      CASE(PROBLEM_STOKES_EQUATION_TYPE)
        CALL STOKES_POST_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
      CASE(PROBLEM_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_POST_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
      CASE(PROBLEM_DARCY_EQUATION_TYPE)
        CALL DARCY_EQUATION_POST_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Problem type "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics problem class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_POST_SOLVE")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_POST_SOLVE",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_POST_SOLVE")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_POST_SOLVE

  !
  !================================================================================================================================


  !>Sets up the output type for a fluid mechanics problem class.
  SUBROUTINE FLUID_MECHANICS_PRE_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FLUID_MECHANICS_PRE_SOLVE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
      SELECT CASE(CONTROL_LOOP%PROBLEM%TYPE)
      CASE(PROBLEM_STOKES_EQUATION_TYPE)
        CALL STOKES_PRE_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
      CASE(PROBLEM_NAVIER_STOKES_EQUATION_TYPE)
        CALL NAVIER_STOKES_PRE_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
      CASE(PROBLEM_DARCY_EQUATION_TYPE)
        CALL DARCY_EQUATION_PRE_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Problem type "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%TYPE,"*",ERR,ERROR))// &
          & " is not valid for a fluid mechanics problem class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FLUID_MECHANICS_PRE_SOLVE")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_PRE_SOLVE",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_PRE_SOLVE")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_PRE_SOLVE

  !
  !================================================================================================================================
  !

  !>Executes before each loop of a control loop, ie before each time step for a time loop
  SUBROUTINE FLUID_MECHANICS_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT

    CALL ENTERS("FLUID_MECHANICS_CONTROL_LOOP_PRE_LOOP",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
      SELECT CASE(CONTROL_LOOP%LOOP_TYPE)
      CASE(PROBLEM_CONTROL_TIME_LOOP_TYPE)
        CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
        CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"====== Starting time step",ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"CURRENT_TIME          = ",CURRENT_TIME,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"TIME_INCREMENT        = ",TIME_INCREMENT,ERR,ERROR,*999)
        IF(DIAGNOSTICS1) THEN
          CALL WRITE_STRING(DIAGNOSTIC_OUTPUT_TYPE,"====== Starting time step",ERR,ERROR,*999)
          CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"CURRENT_TIME          = ",CURRENT_TIME,ERR,ERROR,*999)
          CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"TIME_INCREMENT        = ",TIME_INCREMENT,ERR,ERROR,*999)
        ENDIF
        SELECT CASE(CONTROL_LOOP%PROBLEM%TYPE)
        CASE(PROBLEM_STOKES_EQUATION_TYPE)
          !do nothing
        CASE(PROBLEM_NAVIER_STOKES_EQUATION_TYPE)
          !do nothing
        CASE(PROBLEM_DARCY_EQUATION_TYPE)
          CALL DARCY_CONTROL_TIME_LOOP_PRE_LOOP(CONTROL_LOOP,ERR,ERROR,*999)
        CASE DEFAULT
          LOCAL_ERROR="Problem type "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%TYPE,"*",ERR,ERROR))// &
            & " is not valid for a fluid mechanics problem class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      CASE DEFAULT
        !do nothing
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("FLUID_MECHANICS_CONTROL_LOOP_PRE_LOOP")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_CONTROL_LOOP_PRE_LOOP",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_CONTROL_LOOP_PRE_LOOP")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_CONTROL_LOOP_PRE_LOOP

  !
  !================================================================================================================================
  !

  !>Executes after each loop of a control loop, ie after each time step for a time loop
  SUBROUTINE FLUID_MECHANICS_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP_DARCY
    TYPE(SOLVER_TYPE), POINTER :: SOLVER_DARCY

    CALL ENTERS("FLUID_MECHANICS_CONTROL_LOOP_POST_LOOP",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
      SELECT CASE(CONTROL_LOOP%LOOP_TYPE)
      CASE(PROBLEM_CONTROL_TIME_LOOP_TYPE)
        SELECT CASE(CONTROL_LOOP%PROBLEM%TYPE)
        CASE(PROBLEM_STOKES_EQUATION_TYPE)
          !do nothing
        CASE(PROBLEM_NAVIER_STOKES_EQUATION_TYPE)
          !do nothing
        CASE(PROBLEM_DARCY_EQUATION_TYPE)
          CALL DARCY_CONTROL_TIME_LOOP_POST_LOOP(CONTROL_LOOP,ERR,ERROR,*999)
        CASE DEFAULT
          LOCAL_ERROR="Problem type "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%TYPE,"*",ERR,ERROR))// &
            & " is not valid for a fluid mechanics problem class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      CASE DEFAULT
        !do nothing
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("FLUID_MECHANICS_CONTROL_LOOP_POST_LOOP")
    RETURN
999 CALL ERRORS("FLUID_MECHANICS_CONTROL_LOOP_POST_LOOP",ERR,ERROR)
    CALL EXITS("FLUID_MECHANICS_CONTROL_LOOP_POST_LOOP")
    RETURN 1
  END SUBROUTINE FLUID_MECHANICS_CONTROL_LOOP_POST_LOOP

  !
  !================================================================================================================================
  !

END MODULE FLUID_MECHANICS_ROUTINES

