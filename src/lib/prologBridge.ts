import { spawnSync } from 'child_process';
import { writeFileSync, unlinkSync } from 'fs';
import { join } from 'path';

export interface PatientData {
  nombre: string;
  edad: string;
  sexo: string;
  sintomas: string[];
  contacto: boolean;
  vacunacion: string;
  alergias: string[];
  condiciones: string[];
  historial: string[];
  temperatura?: number | null;
  leucocitos?: number | null;
  pcr?: string;
  feedbackParacetamol?: string;
  feedbackAntihistaminico?: string;
  feedbackSintomas?: string;
}

export interface DiagnosisResult {
  diagnostico: string;
  grave: string;
  prioridad: string;
  tratamientos: string[];
  complicaciones: string[];
  precauciones: string[];
  temperatura_interp: string;
  leucocitos_interp: string;
  recomendaciones: string[];
  manejo: string;
  error?: string;
}

export function runDiagnosis(data: PatientData): DiagnosisResult {
  const pid = 'p_nuevo';
  const tempFile = `/tmp/patient_${Date.now()}.pl`;
  const prologFile = join(process.cwd(), 'varicela.pl');

  try {
    const facts = buildPatientFacts(pid, data);
    writeFileSync(tempFile, facts, 'utf8');

    const result = spawnSync('swipl', [
      '-q',
      '-l', prologFile,
      '-l', tempFile,
      '-g', `consultar_paciente(${pid}), halt`,
      '-t', 'halt'
    ], {
      encoding: 'utf8',
      timeout: 15000
    });

    if (result.error) {
      return errorResult(`SWI-Prolog no encontrado. Instálelo con: sudo pacman -S swi-prolog`);
    }

    const output = result.stdout || '';
    if (!output.includes('DONE')) {
      return errorResult(`Sin diagnóstico posible con los datos ingresados. stderr: ${result.stderr}`);
    }

    return parseOutput(output);
  } finally {
    try { unlinkSync(tempFile); } catch { /* ignore */ }
  }
}

function buildPatientFacts(pid: string, data: PatientData): string {
  const lines: string[] = [];

  lines.push(`paciente(${pid}).`);
  lines.push(`edad(${pid},${data.edad}).`);
  lines.push(`sexo(${pid},${data.sexo}).`);

  for (const s of data.sintomas) {
    lines.push(`presenta(${pid},${s}).`);
  }

  if (data.contacto) {
    lines.push(`tuvo_contacto(${pid},varicela).`);
  }

  lines.push(`vacunacion(${pid},${data.vacunacion}).`);

  const alergias = data.alergias.filter(a => a && a !== 'ninguna');
  if (alergias.length > 0) {
    for (const a of alergias) {
      lines.push(`alergia(${pid},${a}).`);
    }
  } else {
    lines.push(`alergia(${pid},ninguna).`);
  }

  const condiciones = data.condiciones.filter(c => c && c !== 'ninguna');
  if (condiciones.length > 0) {
    for (const c of condiciones) {
      lines.push(`condicion(${pid},${c}).`);
    }
  } else {
    lines.push(`condicion(${pid},ninguna).`);
  }

  const historial = data.historial.filter(h => h && h !== 'ninguno');
  if (historial.length > 0) {
    for (const h of historial) {
      lines.push(`historial(${pid},${h}).`);
    }
  } else {
    lines.push(`historial(${pid},ninguno).`);
  }

  if (data.temperatura != null && !isNaN(Number(data.temperatura))) {
    lines.push(`resultado_lab(${pid},temperatura,${data.temperatura}).`);
  }
  if (data.leucocitos != null && !isNaN(Number(data.leucocitos))) {
    lines.push(`resultado_lab(${pid},leucocitos,${data.leucocitos}).`);
  }
  if (data.pcr && data.pcr !== '') {
    lines.push(`resultado_lab(${pid},pcr,${data.pcr}).`);
  }

  if (data.feedbackParacetamol && data.feedbackParacetamol !== 'na') {
    lines.push(`feedback(${pid},paracetamol,${data.feedbackParacetamol}).`);
  }
  if (data.feedbackAntihistaminico && data.feedbackAntihistaminico !== 'na') {
    lines.push(`feedback(${pid},antihistaminico,${data.feedbackAntihistaminico}).`);
  }
  if (data.feedbackSintomas && data.feedbackSintomas !== 'na') {
    lines.push(`feedback(${pid},sintomas,${data.feedbackSintomas}).`);
  }

  return lines.join('\n') + '\n';
}

function parseOutput(output: string): DiagnosisResult {
  const result: DiagnosisResult = {
    diagnostico: 'sin_diagnostico',
    grave: 'no',
    prioridad: 'sin_datos',
    tratamientos: [],
    complicaciones: [],
    precauciones: [],
    temperatura_interp: 'sin_datos',
    leucocitos_interp: 'sin_datos',
    recomendaciones: [],
    manejo: 'ambulatorio'
  };

  for (const line of output.split('\n')) {
    const eqIdx = line.indexOf('=');
    if (eqIdx === -1) continue;
    const key = line.substring(0, eqIdx).trim();
    const value = line.substring(eqIdx + 1).trim();

    switch (key) {
      case 'DIAGNOSTICO': result.diagnostico = value; break;
      case 'GRAVE': result.grave = value; break;
      case 'PRIORIDAD': result.prioridad = value; break;
      case 'TRATAMIENTOS': result.tratamientos = parseList(value); break;
      case 'COMPLICACIONES': result.complicaciones = parseList(value); break;
      case 'PRECAUCIONES': result.precauciones = parseList(value); break;
      case 'TEMPERATURA_INTERP': result.temperatura_interp = value; break;
      case 'LEUCOCITOS_INTERP': result.leucocitos_interp = value; break;
      case 'RECOMENDACIONES': result.recomendaciones = parseList(value); break;
      case 'MANEJO': result.manejo = value; break;
    }
  }

  return result;
}

function parseList(str: string): string[] {
  if (!str || str === '[]') return [];
  const inner = str.replace(/^\[|\]$/g, '').trim();
  if (!inner) return [];
  return inner.split(',').map(s => s.trim()).filter(Boolean);
}

function errorResult(msg: string): DiagnosisResult {
  return {
    diagnostico: 'error',
    grave: 'no',
    prioridad: 'sin_datos',
    tratamientos: [],
    complicaciones: [],
    precauciones: [],
    temperatura_interp: 'sin_datos',
    leucocitos_interp: 'sin_datos',
    recomendaciones: [],
    manejo: 'sin_datos',
    error: msg
  };
}
