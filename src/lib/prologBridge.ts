import { createRequire } from 'module';
import { readFileSync } from 'fs';
import { join } from 'path';

const require = createRequire(import.meta.url);
const pl = require('tau-prolog');

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

// ---- tau-prolog helpers ----

function consult(session: any, program: string): Promise<void> {
  return new Promise((resolve, reject) => {
    session.consult(program, {
      success: resolve,
      error: (err: any) => reject(new Error(`Prolog load error: ${err}`))
    });
  });
}

function queryFirst(session: any, goal: string, variable: string): Promise<string | null> {
  return new Promise((resolve) => {
    session.query(goal + '.', {
      success: () => {
        session.answer({
          success: (answer: any) => {
            const val = answer.lookup(variable);
            resolve(val ? val.toString() : null);
          },
          fail: () => resolve(null),
          error: () => resolve(null),
          limit: () => resolve(null)
        });
      },
      error: () => resolve(null)
    });
  });
}

function queryExists(session: any, goal: string): Promise<boolean> {
  return new Promise((resolve) => {
    session.query(goal + '.', {
      success: () => {
        session.answer({
          success: () => resolve(true),
          fail: () => resolve(false),
          error: () => resolve(false),
          limit: () => resolve(false)
        });
      },
      error: () => resolve(false)
    });
  });
}

function findAll(session: any, template: string, goal: string, listVar: string): Promise<string[]> {
  return new Promise((resolve) => {
    session.query(`findall(${template}, ${goal}, ${listVar}).`, {
      success: () => {
        session.answer({
          success: (answer: any) => {
            const xs = answer.lookup(listVar);
            resolve(xs ? termListToArray(xs) : []);
          },
          fail: () => resolve([]),
          error: () => resolve([]),
          limit: () => resolve([])
        });
      },
      error: () => resolve([])
    });
  });
}

function termListToArray(term: any): string[] {
  const result: string[] = [];
  let current = term;
  while (current && current.indicator === './2') {
    result.push(current.args[0].toString());
    current = current.args[1];
  }
  return [...new Set(result)]; // deduplicate
}

// ---- main export ----

export async function runDiagnosis(data: PatientData): Promise<DiagnosisResult> {
  const pid = 'p_nuevo';

  try {
    const prologFile = join(process.cwd(), 'varicela.pl');
    let source = readFileSync(prologFile, 'utf8');

    // tau-prolog no soporta :- discontiguous, se filtra
    source = source.split('\n')
      .filter(l => !l.trim().startsWith(':- discontiguous'))
      .join('\n');

    const facts = buildPatientFacts(pid, data);
    const program = source + '\n' + facts;

    const session = pl.create(100000);
    await consult(session, program);

    const diagnostico = await queryFirst(session, `diagnostico_final(${pid}, D)`, 'D') ?? 'sin_diagnostico';
    const grave = await queryExists(session, `caso_grave(${pid})`) ? 'si' : 'no';
    const tratamientos = await findAll(session, 'T', `tratamiento_recomendado(${pid}, T)`, 'Ts');
    const complicaciones = await findAll(session, 'C', `riesgo_complicacion(${pid}, C)`, 'Cs');
    const precauciones = await findAll(session, 'Pr', `precaucion_historial(${pid}, Pr)`, 'Prs');
    const temperatura_interp = await queryFirst(session, `interpretar_temperatura(${pid}, TI)`, 'TI') ?? 'sin_datos';
    const leucocitos_interp = await queryFirst(session, `interpretar_leucocitos(${pid}, LI)`, 'LI') ?? 'sin_datos';
    const recomendaciones = await findAll(session, 'R', `recomendar(${pid}, R)`, 'Rs');

    const esAlta = await queryExists(session, `prioridad_alta(${pid})`);
    const esMedia = !esAlta && await queryExists(session, `prioridad_media(${pid})`);
    const esBaja = !esAlta && !esMedia && await queryExists(session, `prioridad_baja(${pid})`);
    const prioridad = esAlta ? 'alta' : esMedia ? 'media' : esBaja ? 'baja' : 'sin_datos';

    const manejo = await queryExists(session, `derivacion_hospitalaria(${pid})`) ? 'hospitalario' : 'ambulatorio';

    return { diagnostico, grave, prioridad, tratamientos, complicaciones, precauciones, temperatura_interp, leucocitos_interp, recomendaciones, manejo };

  } catch (err) {
    return errorResult(String(err));
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
    for (const a of alergias) lines.push(`alergia(${pid},${a}).`);
  } else {
    lines.push(`alergia(${pid},ninguna).`);
  }

  const condiciones = data.condiciones.filter(c => c && c !== 'ninguna');
  if (condiciones.length > 0) {
    for (const c of condiciones) lines.push(`condicion(${pid},${c}).`);
  } else {
    lines.push(`condicion(${pid},ninguna).`);
  }

  const historial = data.historial.filter(h => h && h !== 'ninguno');
  if (historial.length > 0) {
    for (const h of historial) lines.push(`historial(${pid},${h}).`);
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

function errorResult(msg: string): DiagnosisResult {
  return {
    diagnostico: 'error', grave: 'no', prioridad: 'sin_datos',
    tratamientos: [], complicaciones: [], precauciones: [],
    temperatura_interp: 'sin_datos', leucocitos_interp: 'sin_datos',
    recomendaciones: [], manejo: 'sin_datos', error: msg
  };
}
