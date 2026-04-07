% ==========================================
% SISTEMA EXPERTO - DIAGNÓSTICO DE VARICELA
% ==========================================

:- discontiguous paciente/1.
:- discontiguous edad/2.
:- discontiguous sexo/2.
:- discontiguous presenta/2.
:- discontiguous tuvo_contacto/2.
:- discontiguous vacunacion/2.
:- discontiguous alergia/2.
:- discontiguous condicion/2.
:- discontiguous resultado_lab/3.
:- discontiguous historial/2.
:- discontiguous feedback/3.

%% ---- HECHOS: PACIENTES DE EJEMPLO ----

paciente(juan).
paciente(maria).
paciente(pedro).
paciente(ana).
paciente(luis).

edad(juan,nino).
edad(maria,adulto).
edad(pedro,nino).
edad(ana,adulto).
edad(luis,adulto).

sexo(juan,masculino).
sexo(maria,femenino).
sexo(pedro,masculino).
sexo(ana,femenino).
sexo(luis,masculino).

presenta(juan,fiebre).
presenta(juan,erupcion_cutanea).
presenta(juan,vesiculas).
presenta(juan,picazon).
presenta(juan,malestar_general).
presenta(juan,dolor_cabeza).
presenta(juan,fatiga).

presenta(maria,fiebre).
presenta(maria,erupcion_cutanea).
presenta(maria,picazon).
presenta(maria,malestar_general).

presenta(pedro,fiebre).
presenta(pedro,tos).
presenta(pedro,dolor_garganta).

presenta(ana,erupcion_cutanea).
presenta(ana,vesiculas).
presenta(ana,picazon).
presenta(ana,fiebre).
presenta(ana,malestar_general).

presenta(luis,fiebre).
presenta(luis,erupcion_cutanea).
presenta(luis,vesiculas).
presenta(luis,picazon).
presenta(luis,dificultad_respiratoria).

tuvo_contacto(juan,varicela).
tuvo_contacto(maria,varicela).
tuvo_contacto(ana,varicela).
tuvo_contacto(luis,varicela).

vacunacion(juan,incompleta).
vacunacion(maria,ninguna).
vacunacion(pedro,completa).
vacunacion(ana,incompleta).
vacunacion(luis,ninguna).

% Múltiples alergias por paciente (soporte multi-alergia)
alergia(juan,ninguna).
alergia(maria,paracetamol).
alergia(pedro,ninguna).
alergia(ana,ninguna).
alergia(luis,antihistaminico).

condicion(juan,ninguna).
condicion(maria,embarazo).
condicion(pedro,ninguna).
condicion(ana,ninguna).
condicion(luis,inmunosupresion).

% Resultados de laboratorio
resultado_lab(juan,temperatura,38.8).
resultado_lab(maria,temperatura,39.2).
resultado_lab(pedro,temperatura,37.5).
resultado_lab(ana,temperatura,38.5).
resultado_lab(luis,temperatura,39.9).

resultado_lab(juan,leucocitos,8500).
resultado_lab(maria,leucocitos,11000).
resultado_lab(pedro,leucocitos,7200).
resultado_lab(ana,leucocitos,9000).
resultado_lab(luis,leucocitos,14000).

resultado_lab(juan,pcr,bajo).
resultado_lab(maria,pcr,moderado).
resultado_lab(pedro,pcr,normal).
resultado_lab(ana,pcr,bajo).
resultado_lab(luis,pcr,alto).

% Historial médico - múltiples entradas por paciente
historial(juan,ninguno).
historial(maria,hipertension).
historial(pedro,asma).
historial(ana,ninguno).
historial(luis,diabetes).

% Feedback del paciente sobre medicamentos y síntomas
feedback(juan,paracetamol,tolera_bien).
feedback(maria,antihistaminico,tolera_bien).
feedback(ana,paracetamol,tolera_bien).
feedback(luis,paracetamol,tolera_bien).

%% ---- BASE DE CONOCIMIENTO MÉDICO ----

sintoma_clave(varicela,fiebre).
sintoma_clave(varicela,erupcion_cutanea).
sintoma_clave(varicela,vesiculas).
sintoma_clave(varicela,picazon).

sintoma_secundario(varicela,malestar_general).
sintoma_secundario(varicela,dolor_cabeza).
sintoma_secundario(varicela,fatiga).
sintoma_secundario(varicela,perdida_apetito).
sintoma_secundario(varicela,dolor_garganta).

factor_riesgo(varicela,embarazo).
factor_riesgo(varicela,inmunosupresion).
factor_riesgo(varicela,adulto).
factor_riesgo(varicela,diabetes).
factor_riesgo(varicela,asma).

complicacion_asociada(varicela,neumonia).
complicacion_asociada(varicela,infeccion_bacteriana).
complicacion_asociada(varicela,encefalitis).
complicacion_asociada(varicela,sobreinfeccion_cutanea).

tratamiento_indicado(varicela,paracetamol).
tratamiento_indicado(varicela,antihistaminico).
tratamiento_indicado(varicela,hidratacion).
tratamiento_indicado(varicela,aislamiento).
tratamiento_indicado(varicela,reposo).

tratamiento_grave(varicela,aciclovir).

contraindicado(paracetamol,paracetamol).
contraindicado(antihistaminico,antihistaminico).
contraindicado(aciclovir,insuficiencia_renal).

prueba_clinica(varicela,inspeccion_lesiones).
prueba_clinica(varicela,evaluacion_temperatura).
prueba_clinica(varicela,anamnesis_contacto).
prueba_clinica(varicela,hemograma_completo).
prueba_clinica(varicela,pcr_proteina_c).

recomendacion_general(varicela,evitar_rascado).
recomendacion_general(varicela,usar_ropa_ligera).
recomendacion_general(varicela,mantener_hidratacion).
recomendacion_general(varicela,aislamiento_domiciliario).
recomendacion_general(varicela,cortar_unas).

%% ---- REGLAS: SÍNTOMAS ----

tiene_sintoma_clave(P,S) :-
    presenta(P,S),
    sintoma_clave(varicela,S).

tiene_sintoma_secundario(P,S) :-
    presenta(P,S),
    sintoma_secundario(varicela,S).

cuenta_sintomas_clave(P,N) :-
    findall(S, tiene_sintoma_clave(P,S), Ls),
    length(Ls,N).

%% ---- REGLAS: SOSPECHA Y DIAGNÓSTICO ----

sospecha_inicial_varicela(P) :-
    presenta(P,fiebre),
    presenta(P,erupcion_cutanea).

sospecha_moderada_varicela(P) :-
    presenta(P,fiebre),
    presenta(P,erupcion_cutanea),
    presenta(P,picazon).

varicela_probable(P) :-
    presenta(P,fiebre),
    presenta(P,erupcion_cutanea),
    presenta(P,vesiculas),
    presenta(P,picazon).

varicela_probable(P) :-
    sospecha_moderada_varicela(P),
    tuvo_contacto(P,varicela).

varicela_probable(P) :-
    sospecha_moderada_varicela(P),
    fiebre_clinica(P).

diagnostico(P,varicela) :-
    varicela_probable(P).

%% ---- REGLAS: INTERPRETACIÓN DE LABORATORIO ----

interpretar_temperatura(P,Interpretacion) :-
    resultado_lab(P,temperatura,T),
    (T < 37.5 -> Interpretacion = normal ;
     T < 38.0 -> Interpretacion = subfebril ;
     T < 39.0 -> Interpretacion = fiebre_moderada ;
     T < 40.0 -> Interpretacion = fiebre_alta ;
     Interpretacion = fiebre_muy_alta).

interpretar_leucocitos(P,Interpretacion) :-
    resultado_lab(P,leucocitos,L),
    (L < 4000 -> Interpretacion = leucopenia ;
     L =< 10000 -> Interpretacion = normal ;
     L =< 15000 -> Interpretacion = leucocitosis_leve ;
     L =< 20000 -> Interpretacion = leucocitosis_moderada ;
     Interpretacion = leucocitosis_severa).

interpretar_pcr(P,Interpretacion) :-
    resultado_lab(P,pcr,Interpretacion).

resultado_lab_critico(P,temperatura) :-
    resultado_lab(P,temperatura,T),
    T >= 40.0.

resultado_lab_critico(P,leucocitos) :-
    resultado_lab(P,leucocitos,L),
    L > 20000.

resultado_lab_anormal(P,temperatura) :-
    resultado_lab(P,temperatura,T),
    T >= 38.0.

resultado_lab_anormal(P,leucocitos) :-
    resultado_lab(P,leucocitos,L),
    L > 10000.

resultado_lab_anormal(P,pcr) :-
    resultado_lab(P,pcr,V),
    (V = moderado ; V = alto).

%% ---- REGLAS: FIEBRE Y LABORATORIO ----

fiebre_clinica(P) :-
    resultado_lab(P,temperatura,T),
    T >= 38.0.

fiebre_alta(P) :-
    resultado_lab(P,temperatura,T),
    T >= 39.0.

fiebre_muy_alta(P) :-
    resultado_lab(P,temperatura,T),
    T >= 40.0.

leucocitosis(P) :-
    resultado_lab(P,leucocitos,L),
    L > 10000.

inflamacion_sistemica(P) :-
    resultado_lab(P,pcr,alto).

inflamacion_sistemica(P) :-
    resultado_lab(P,pcr,moderado).

diagnostico_confirmado_lab(P,varicela) :-
    varicela_probable(P),
    fiebre_clinica(P).

riesgo_aumentado_lab(P) :-
    varicela_probable(P),
    leucocitosis(P).

riesgo_aumentado_lab(P) :-
    varicela_probable(P),
    inflamacion_sistemica(P).

%% ---- REGLAS: ALERGIAS MÚLTIPLES ----

tiene_alergia(P,Med) :-
    alergia(P,Med),
    Med \= ninguna.

sin_alergias(P) :-
    alergia(P,ninguna).

sin_alergias(P) :-
    \+ alergia(P,_).

%% ---- REGLAS: PRECAUCIONES POR HISTORIAL ----

precaucion_historial(P,monitoreo_cardiaco) :-
    historial(P,hipertension),
    varicela_probable(P).

precaucion_historial(P,control_glucemia) :-
    historial(P,diabetes),
    varicela_probable(P).

precaucion_historial(P,cuidado_respiratorio) :-
    historial(P,asma),
    presenta(P,fiebre).

precaucion_historial(P,vigilancia_renal) :-
    historial(P,enfermedad_renal),
    varicela_probable(P).

%% ---- REGLAS: FEEDBACK DEL PACIENTE ----

tratamiento_tolerado(P,Med) :-
    feedback(P,Med,tolera_bien).

tratamiento_no_tolerado(P,Med) :-
    feedback(P,Med,no_tolera).

ajuste_por_feedback(P,suspender,Med) :-
    feedback(P,Med,no_tolera),
    tratamiento_recomendado(P,Med).

ajuste_por_feedback(P,continuar,Med) :-
    feedback(P,Med,tolera_bien),
    tratamiento_recomendado(P,Med).

feedback_mejora(P) :-
    feedback(P,sintomas,mejorando).

feedback_empeora(P) :-
    feedback(P,sintomas,empeorando).

alerta_por_feedback(P) :-
    feedback_empeora(P),
    varicela_probable(P).

%% ---- REGLAS: RIESGO Y GRAVEDAD ----

paciente_riesgo(P) :-
    condicion(P,embarazo).

paciente_riesgo(P) :-
    condicion(P,inmunosupresion).

paciente_riesgo(P) :-
    edad(P,adulto),
    varicela_probable(P).

paciente_riesgo(P) :-
    historial(P,diabetes),
    varicela_probable(P).

paciente_riesgo(P) :-
    historial(P,asma),
    varicela_probable(P).

caso_grave(P) :-
    varicela_probable(P),
    condicion(P,inmunosupresion).

caso_grave(P) :-
    varicela_probable(P),
    presenta(P,dificultad_respiratoria).

caso_grave(P) :-
    varicela_probable(P),
    condicion(P,embarazo).

caso_grave(P) :-
    varicela_probable(P),
    fiebre_alta(P),
    leucocitosis(P).

caso_grave(P) :-
    varicela_probable(P),
    fiebre_muy_alta(P).

caso_grave(P) :-
    varicela_probable(P),
    feedback_empeora(P),
    paciente_riesgo(P).

%% ---- REGLAS: COMPLICACIONES ----

riesgo_complicacion(P,neumonia) :-
    varicela_probable(P),
    presenta(P,dificultad_respiratoria).

riesgo_complicacion(P,neumonia) :-
    varicela_probable(P),
    condicion(P,inmunosupresion).

riesgo_complicacion(P,infeccion_bacteriana) :-
    varicela_probable(P),
    presenta(P,vesiculas).

riesgo_complicacion(P,sobreinfeccion_cutanea) :-
    varicela_probable(P),
    presenta(P,vesiculas),
    \+ feedback(P,cuidado_lesiones,adecuado).

riesgo_complicacion(P,encefalitis) :-
    varicela_probable(P),
    condicion(P,inmunosupresion),
    fiebre_alta(P).

riesgo_complicacion(P,complicacion_general) :-
    caso_grave(P).

%% ---- REGLAS: TRATAMIENTO ----

requiere_aislamiento(P) :-
    varicela_probable(P).

requiere_reposo(P) :-
    varicela_probable(P).

requiere_hidratacion(P) :-
    varicela_probable(P).

puede_usar(P,paracetamol) :-
    varicela_probable(P),
    \+ tiene_alergia(P,paracetamol),
    \+ tratamiento_no_tolerado(P,paracetamol).

puede_usar(P,antihistaminico) :-
    varicela_probable(P),
    \+ tiene_alergia(P,antihistaminico),
    \+ tratamiento_no_tolerado(P,antihistaminico).

puede_usar(P,aciclovir) :-
    requiere_aciclovir(P),
    \+ tiene_alergia(P,aciclovir),
    \+ historial(P,insuficiencia_renal).

no_puede_usar(P,paracetamol) :-
    tiene_alergia(P,paracetamol).

no_puede_usar(P,paracetamol) :-
    tratamiento_no_tolerado(P,paracetamol).

no_puede_usar(P,antihistaminico) :-
    tiene_alergia(P,antihistaminico).

no_puede_usar(P,antihistaminico) :-
    tratamiento_no_tolerado(P,antihistaminico).

requiere_aciclovir(P) :-
    caso_grave(P).

tratamiento_recomendado(P,paracetamol) :-
    puede_usar(P,paracetamol).

tratamiento_recomendado(P,antihistaminico) :-
    puede_usar(P,antihistaminico).

tratamiento_recomendado(P,hidratacion) :-
    varicela_probable(P).

tratamiento_recomendado(P,reposo) :-
    varicela_probable(P).

tratamiento_recomendado(P,aislamiento) :-
    varicela_probable(P).

tratamiento_recomendado(P,aciclovir) :-
    puede_usar(P,aciclovir).

tratamiento_alternativo(P,ibuprofeno) :-
    no_puede_usar(P,paracetamol),
    varicela_probable(P),
    \+ tiene_alergia(P,ibuprofeno).

%% ---- REGLAS: RECOMENDACIONES ----

recomendar(P,evitar_rascado) :-
    varicela_probable(P).

recomendar(P,usar_ropa_ligera) :-
    varicela_probable(P).

recomendar(P,mantener_hidratacion) :-
    varicela_probable(P).

recomendar(P,aislamiento_domiciliario) :-
    varicela_probable(P).

recomendar(P,cortar_unas) :-
    varicela_probable(P),
    presenta(P,picazon).

recomendar(P,bano_agua_tibia) :-
    varicela_probable(P),
    presenta(P,picazon).

%% ---- REGLAS: NECESIDAD DE PRUEBAS ----

necesita_prueba(P,inspeccion_lesiones) :-
    cuadro_compatible_varicela(P).

necesita_prueba(P,evaluacion_temperatura) :-
    presenta(P,fiebre).

necesita_prueba(P,anamnesis_contacto) :-
    tuvo_contacto(P,varicela).

necesita_prueba(P,hemograma_completo) :-
    caso_grave(P).

necesita_prueba(P,pcr_proteina_c) :-
    riesgo_aumentado_lab(P).

%% ---- REGLAS: PRIORIDAD Y TRIAGE ----

debe_acudir_medico(P) :-
    varicela_probable(P).

debe_acudir_urgente(P) :-
    caso_grave(P).

prioridad_alta(P) :-
    caso_grave(P).

prioridad_alta(P) :-
    alerta_por_feedback(P).

prioridad_media(P) :-
    varicela_probable(P),
    \+ caso_grave(P).

prioridad_baja(P) :-
    sospecha_baja_varicela(P).

%% ---- REGLAS: VACUNACIÓN Y CONTAGIO ----

descartado_varicela(P) :-
    paciente(P),
    \+ presenta(P,erupcion_cutanea),
    \+ presenta(P,vesiculas).

sospecha_baja_varicela(P) :-
    presenta(P,fiebre),
    \+ presenta(P,erupcion_cutanea).

protegido_parcialmente(P) :-
    vacunacion(P,completa).

riesgo_elevado_contagio(P) :-
    vacunacion(P,ninguna),
    tuvo_contacto(P,varicela).

riesgo_medio_contagio(P) :-
    vacunacion(P,incompleta),
    tuvo_contacto(P,varicela).

%% ---- REGLAS: CUADROS CLÍNICOS ----

cuadro_clasico_varicela(P) :-
    presenta(P,fiebre),
    presenta(P,erupcion_cutanea),
    presenta(P,vesiculas),
    presenta(P,picazon).

cuadro_compatible_varicela(P) :-
    presenta(P,fiebre),
    presenta(P,erupcion_cutanea),
    presenta(P,picazon).

%% ---- REGLAS: DERIVACIÓN ----

tratamiento_basico_completo(P) :-
    tratamiento_recomendado(P,hidratacion),
    tratamiento_recomendado(P,reposo),
    tratamiento_recomendado(P,aislamiento).

manejo_ambulatorio(P) :-
    varicela_probable(P),
    \+ caso_grave(P).

derivacion_hospitalaria(P) :-
    caso_grave(P).

%% ---- REGLAS: DIAGNÓSTICO FINAL ----

diagnostico_final(P,varicela_leve) :-
    varicela_probable(P),
    \+ caso_grave(P).

diagnostico_final(P,varicela_grave) :-
    caso_grave(P).

diagnostico_final(P,descartado) :-
    descartado_varicela(P).

%% ---- REGLA PRINCIPAL DE CONSULTA ----
% Usada por la interfaz web para obtener resultados parseables

consultar_paciente(P) :-
    (diagnostico_final(P,D) -> true ; D = sin_diagnostico),
    (caso_grave(P) -> Grave = si ; Grave = no),
    findall(T, tratamiento_recomendado(P,T), Tratamientos),
    list_to_set(Tratamientos, TratSet),
    findall(C, riesgo_complicacion(P,C), Comps),
    list_to_set(Comps, CompSet),
    findall(Pr, precaucion_historial(P,Pr), Precs),
    list_to_set(Precs, PrecSet),
    (interpretar_temperatura(P,TempI) -> true ; TempI = sin_datos),
    (interpretar_leucocitos(P,LeucoI) -> true ; LeucoI = sin_datos),
    findall(R, recomendar(P,R), Recs),
    list_to_set(Recs, RecSet),
    (prioridad_alta(P) -> Prio = alta ;
     prioridad_media(P) -> Prio = media ;
     prioridad_baja(P) -> Prio = baja ;
     Prio = sin_datos),
    (derivacion_hospitalaria(P) -> Manejo = hospitalario ; Manejo = ambulatorio),
    format("DIAGNOSTICO=~w~n", [D]),
    format("GRAVE=~w~n", [Grave]),
    format("TRATAMIENTOS=~w~n", [TratSet]),
    format("COMPLICACIONES=~w~n", [CompSet]),
    format("PRECAUCIONES=~w~n", [PrecSet]),
    format("TEMPERATURA_INTERP=~w~n", [TempI]),
    format("LEUCOCITOS_INTERP=~w~n", [LeucoI]),
    format("RECOMENDACIONES=~w~n", [RecSet]),
    format("PRIORIDAD=~w~n", [Prio]),
    format("MANEJO=~w~n", [Manejo]),
    format("DONE~n").
