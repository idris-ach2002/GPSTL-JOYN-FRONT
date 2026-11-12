#!/usr/bin/env node
/**
 * JOYN — deterministic fictional data for an AUTHORIZED TEST DATABASE.
 * Node.js 22+, no dependencies. Dry run by default. Does not create admins:
 * the deployed Spring Boot API has no provision-admin endpoint.
 *
 * node scripts/seed-joyn.js
 * JOYN_SEED_PASSWORD='change-me-on-test-db' node scripts/seed-joyn.js \
 *   --base-url https://your-staging-back.example.org --execute \
 *   --confirm-host your-staging-back.example.org
 *
 * The production Render hostname requires an additional --allow-production.
 * Do not run that option without the backend team's explicit agreement.
 */
const { readFile, writeFile, rename, mkdir } = require('node:fs/promises');
const { dirname, resolve } = require('node:path');
const { URL } = require('node:url');

const DEFAULTS = Object.freeze({ candidates: 250, recruiters: 60,
  companies: 30, offers: 300, applications: 400,
  seed: 20261112, concurrency: 2, rps: 3,
  state: './.joyn-seed-state.json',
  baseUrl: 'http://localhost:8080',
});
const FIRST = ['Camille','Alexandre','Inès','Mehdi','Sarah','Mathis','Yasmine','Nicolas',
  'Léa','Rayan','Nora','Thomas','Fatou','Emma','Sami','Julie','Hugo','Sofia','Victor',
  'Maya','Amine','Chloé','Bilal','Lina','Lucie','Noah','Anaïs','Raphaël','Amina','Enzo',
  'Maëlle','Yanis','Salomé','Antoine','Nadia','Arthur','Elisa','Malik','Sana','Lucas'];
const LAST = ['Laurent','Moreau','Diallo','Benali','Petit','Robert','Lefebvre','Garcia',
  'Fournier','Leroy','Nguyen','Martin','Chevalier','Boucher','Dupont','Bertrand','Haddad',
  'Sow','Lambert','Michel','Khan','Dumas','Girard','Cohen','Muller','Rousseau',
  'Belaïd','Dubois','Faure','Noël','Brahimi','Aubert','Traoré','Garnier','Roux','Perrin',
  'Bailly','Marchand','Legrand','Colin'];
const CITIES = ['Paris','Lyon','Lille','Bordeaux','Nantes','Toulouse','Montpellier',
  'Rennes','Strasbourg','Grenoble','Marseille','Rouen','Tours','Reims'];
const THEMES = [
  { sector: 'Logiciel', name: 'Ingénierie logicielle', title: 'Développeur Full Stack',
    skills: ['TypeScript','React','Java','Spring Boot','PostgreSQL','Git','Docker'] },
  { sector: 'Données', name: 'Ingénierie des données', title: 'Data Analyst',
    skills: ['Python','SQL','Power BI','Pandas','PostgreSQL','Data visualisation'] },
  { sector: 'Cloud', name: 'Plateformes cloud', title: 'Ingénieur DevOps',
    skills: ['Docker','Kubernetes','Linux','Terraform','AWS','CI/CD'] },
  { sector: 'Design', name: 'Design produit', title: 'Designer UX/UI',
    skills: ['Figma','Prototypage','Recherche utilisateur','Design system','Accessibilité'] },
  { sector: 'Cybersécurité', name: 'Sécurité applicative', title: 'Analyste cybersécurité',
    skills: ['Python','Linux','Réseau','SIEM','Sécurité web','Audit'] },
  { sector: 'Business', name: 'Marketing numérique', title: 'Chargé de marketing digital',
    skills: ['SEO','Analytics','Rédaction','Campagnes','CRM','Excel'] },
  { sector: 'Finance', name: 'Finance et contrôle', title: 'Analyste financier',
    skills: ['Excel','Power BI','Reporting','Finance','SQL','Analyse financière'] },
  { sector: 'Produit', name: 'Gestion de produit', title: 'Assistant Product Manager',
    skills: ['Agile','Jira','Figma','Analyse produit','Roadmap','SQL'] },
  { sector: 'Mobile', name: 'Applications mobiles', title: 'Développeur mobile Flutter',
    skills: ['Flutter','Dart','Git','API REST','Tests','Firebase'] },
  { sector: 'Infrastructure', name: 'Systèmes et réseaux', title: 'Administrateur systèmes',
    skills: ['Linux','Réseau','Docker','Bash','Monitoring','Sécurité'] },
];
const CO_PREFIX = ['Atelier','Maison','Collectif','Studio','Groupe','Laboratoire',
  'Horizon','Nouvelle Vague','Nova','Nébula','Équinoxe','Cap','Altitude','Latitude','Aube'];
const CO_SUFFIX = ['Numérique','Solutions','Technologies','Créations','Conseil','Énergie',
  'Data','Services','Digital','Innovations'];
const POSITIONS = ['junior','en alternance','en stage','confirmé'];
const pad = x => String(x).padStart(2,'0');

function parseArgs(argv) {
  const opts = { ...DEFAULTS, execute: false, allowProduction: false, resume: false };
  const fields = new Set(['candidates','recruiters','companies','offers','applications','seed','concurrency','rps']);
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--execute') { opts.execute = true; continue; }
    if (a === '--allow-production') { opts.allowProduction = true; continue; }
    if (a === '--resume') { opts.resume = true; continue; }
    if (a === '--help' || a === '-h') { usage(); process.exit(0); }
    if (!a.startsWith('--') || !argv[i+1]) throw Error(`Option invalide : ${a}`);
    const key = a.slice(2).replaceAll('-', '');
    const name = { baseurl: 'baseUrl', confirmhost: 'confirmHost',
      state: 'state' }[key] ?? key;
    if (!(fields.has(name) || ['baseUrl','confirmHost','state'].includes(name))) throw Error(`Option inconnue : ${a}`);
    const value = argv[++i];
    opts[name] = fields.has(name) ? Number(value) : value;
  }
  for (const f of fields) if (!Number.isInteger(opts[f]) || opts[f] < (f === 'seed' ? 0 : 1)) throw Error(`--${f} doit être un entier positif`);
  if (opts.recruiters < opts.companies) throw Error('Chaque entreprise nécessite au moins un recruteur.');
  if (opts.applications > opts.candidates * opts.offers) throw Error('Trop de candidatures pour les profils et offres choisis.');
  if (opts.concurrency > 5 || opts.rps > 10) throw Error('Limites de sécurité : --concurrency <= 5, --rps <= 10.');
  const uri = new URL(opts.baseUrl);
  if (!['http:','https:'].includes(uri.protocol)) throw Error('Base URL HTTP(S) requise');
  if (opts.execute) {
    if (!opts.confirmHost || opts.confirmHost !== uri.hostname) throw Error('Fournir --confirm-host avec le nom exact de votre serveur.');
    if (!process.env.JOYN_SEED_PASSWORD || process.env.JOYN_SEED_PASSWORD.length < 12) throw Error('JOYN_SEED_PASSWORD (12 caractères minimum) requis.');
    if (/(onrender\.com|workers\.dev|joynpstl)/i.test(uri.hostname) && !opts.allowProduction)
      throw Error('Refus de peupler une URL déployée sans --allow-production. Préférez une base de test.');
  }
  opts.baseUrl = uri.origin;
  opts.state = resolve(opts.state);
  return opts;
}
function usage() { console.log(`JOYN seed (simulation par défaut)
--candidates 250 --recruiters 60 --companies 30 --offers 300 --applications 400
--seed 20261112 --concurrency 2 --rps 3 --state .joyn-seed-state.json
--base-url http://localhost:8080 --resume --execute --confirm-host <host>
--allow-production (autorisation supplémentaire pour une URL déployée)
JOYN_SEED_PASSWORD=<mot de passe des comptes fictifs>
Pas de création d'administrateur : endpoint absent.`); }
function random(seed) { let s = seed >>> 0; return () => { s ^= s << 13; s ^= s >>> 17; s ^= s << 5; return (s >>> 0) / 4294967296; }; }
function shuffle(list, rng) { const out = [...list]; for(let i=out.length-1;i>0;i--) { const j = Math.floor(rng()*(i+1)); [out[i],out[j]]=[out[j],out[i]]; } return out; }
function choose(list, rng) { return list[Math.floor(rng()*list.length)]; }
function slug(s) { return s.normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-zA-Z0-9]+/g,'.').replace(/^\.|\.$/g,'').toLowerCase(); }
function scenario(opts) {
  const rng = random(opts.seed), people = shuffle(FIRST.flatMap(firstName => LAST.map(lastName => ({firstName,lastName}))), rng);
  const companies = Array.from({length:opts.companies}, (_,i) => ({
    name: `${CO_PREFIX[i % CO_PREFIX.length]} ${CO_SUFFIX[Math.floor(i / CO_PREFIX.length) % CO_SUFFIX.length]} ${i>=CO_PREFIX.length*CO_SUFFIX.length ? 'France':''}`.trim(),
    theme: i % THEMES.length, city: CITIES[i % CITIES.length],
  }));
  // More companies than the prefix/suffix dictionary: provide a reproducible, unique suffix.
  const used = new Set();
  for (const company of companies) { const base=company.name;let k=2;while(used.has(company.name))company.name=`${base} ${k++}`;used.add(company.name); }
  const recruiters = Array.from({length:opts.recruiters}, (_,i) => ({
    ...people[i], companyIndex: i % companies.length,
    email: `${slug(people[i].firstName)}.${slug(people[i].lastName)}.${slug(companies[i%companies.length].name).replaceAll('.','-')}@recruteurs.example.test`,
  }));
  const candidates = Array.from({length:opts.candidates}, (_,i) => {
    const person = people[i + opts.recruiters];
    const theme = i % THEMES.length;
    return {...person, theme, city: CITIES[(i+theme)%CITIES.length],
      email: `${slug(person.firstName)}.${slug(person.lastName)}@candidats.example.test`};
  });
  const offers = Array.from({length:opts.offers}, (_,i) => {
    const companyIndex = i % companies.length;
    const theme = companies[companyIndex].theme;
    const t = THEMES[theme];
    const position = POSITIONS[(Math.floor(i/companies.length)) % POSITIONS.length];
    const contract_type = position === 'en stage' ? 'INTERNSHIP' : position === 'en alternance' ? 'APPRENTICESHIP' : 'CDI';
    const title = `${t.title} ${position}`;
    return {ownerIndex: companyIndex, theme,
      body: {
        title, contract_type, location: companies[companyIndex].city,
        remote_policy: i % 3 === 0 ? 'REMOTE' : i % 3 === 1 ? 'HYBRID' : 'ONSITE',
        experience_level: position === 'confirmé' ? 'MID' : 'JUNIOR',
        description: `Au sein de ${companies[companyIndex].name}, vous participerez à ${t.name.toLowerCase()}. Vous travaillerez sur des projets concrets avec une équipe pluridisciplinaire, contribuerez aux revues de qualité et présenterez vos réalisations. Un accompagnement technique est prévu.`,
        salary_min: contract_type === 'CDI' ? 35000 : 1150,
        salary_max: contract_type === 'CDI' ? 44000 : 1600,
        currency: 'EUR', salary_period: contract_type === 'CDI' ? 'YEAR' : 'MONTH',
        skills: t.skills.slice(0, 4 + (i % 3)),
        status: i % 10 === 0 ? 'DRAFT' : 'PUBLISHED',
        ...(contract_type === 'APPRENTICESHIP' ? {rhythm_type:'3 sem / 1 sem',
          start_date:'2027-09-01',duration_months:12,degree_level_required:'BAC_5'} : {}),
      }};
  });
  const published = offers.map((o,i) => o.body.status === 'PUBLISHED' ? i : null).filter(i => i!==null);
  const applications = [], seen = new Set(); let trial=0;
  while (applications.length < opts.applications && trial++ < opts.applications*1000) {
    const candidateIndex = Math.floor(rng()*candidates.length);
    const candidate=candidates[candidateIndex];
    const relevant = published.filter(index => offers[index].theme === candidate.theme);
    const offerIndex= choose(relevant.length ? relevant : published, rng);
    const key = `${candidateIndex}:${offerIndex}`;
    if (seen.has(key)) continue; seen.add(key);
    applications.push({ candidateIndex, offerIndex });
  }
  if(applications.length<opts.applications) throw Error('Impossible de créer toutes les candidatures uniques demandées.');
  return {companies,recruiters,candidates,offers,applications};
}

const sleep = ms => new Promise(r => setTimeout(r,ms));
function createApi(opts) {
  let next = 0;
  async function throttle() { const delay = Math.max(1000/opts.rps,0); const now=Date.now();const scheduled=Math.max(now,next);next=scheduled+delay;await sleep(scheduled-now); }
  return async function call(method,path,{body,token,multipart=false}={}) {
    for(let attempt=0;attempt<5;attempt++) {
      await throttle();
      const headers = {Accept:'application/json', ...(token ? {Authorization:`Bearer ${token}`} : {})};
      const data = multipart ? new FormData() : undefined;
      if(multipart) { for(const [k,v] of Object.entries(body??{})) data.set(k,String(v)); }
      else if(body!==undefined) headers['Content-Type']='application/json';
      const res = await fetch(`${opts.baseUrl}${path}`, {
        method, headers, body:multipart ? data : body === undefined ? undefined : JSON.stringify(body),
        signal:AbortSignal.timeout(30000),
      });
      const raw=await res.text();let json;
      try { json=raw ? JSON.parse(raw) : null; } catch { json={message:raw.slice(0,200)}; }
      if([429,502,503,504].includes(res.status) && attempt<4) {
        const after=Number(res.headers.get('retry-after'));
        await sleep(Number.isFinite(after)&&after>0 ? Math.min(after*1000,30000) : (attempt+1)*1200);
        continue;
      }
      if(!res.ok) throw Object.assign(new Error(`${method} ${path}: HTTP ${res.status} ${String(json?.message ?? json?.error ?? raw).slice(0,220)}`),{status:res.status});
      return json;
    }
  };
}
function newState(opts) { return {version:1,seed:opts.seed,counts:Object.fromEntries(['candidates','recruiters','companies','offers','applications'].map(k=>[k,opts[k]])),
  recruiters:{}, candidates:{}, offers:{}, applications:{}}; }
async function loadState(opts) {
  if(!opts.resume) return newState(opts);
  const prior=JSON.parse(await readFile(opts.state,'utf8'));
  if(prior.version!==1 || prior.seed!==opts.seed || Object.keys(prior.counts).some(k=>prior.counts[k]!==opts[k]))
    throw Error('Le fichier de reprise ne correspond pas aux paramètres demandés.');
  return prior;
}
function createSaver(opts,state) {
  let queue=Promise.resolve();
  return () => queue=queue.then(async()=>{
    await mkdir(dirname(opts.state),{recursive:true});
    const tmp=`${opts.state}.tmp`;
    await writeFile(tmp,JSON.stringify(state,null,2),{mode:0o600});await rename(tmp,opts.state);
  });
}
async function parallel(length,concurrency,task) {
  let index=0; const errors=[];
  await Promise.all(Array.from({length:Math.min(length,concurrency)}, async()=>{
    while(index<length) { const i=index++;try { await task(i); } catch(err){errors.push({index:i,error:String(err.message??err)});console.error(`[ERREUR ${i}] ${err.message??err}`);} }
  }));
  return errors;
}
async function run() {
  const opts=parseArgs(process.argv.slice(2)), model=scenario(opts);
  console.log('JOYN — scénario fictif déterministe',JSON.stringify({
    dryRun:!opts.execute,host:new URL(opts.baseUrl).hostname,
    companies:model.companies.length,recruiters:model.recruiters.length,
    offers:model.offers.length,candidates:model.candidates.length,
    applications:model.applications.length,seed:opts.seed,
    exampleCompany:model.companies[0].name,
    exampleCandidate:`${model.candidates[0].firstName} ${model.candidates[0].lastName}`,
    exampleOffer:model.offers[0].body.title,
  },null,2));
  if(!opts.execute) { console.log('DRY RUN : aucune requête réseau ni écriture sur la base. Utilisez --help pour les options.');return; }
  const api=createApi(opts),state=await loadState(opts),save=createSaver(opts,state);
  const secret=process.env.JOYN_SEED_PASSWORD;
  const tokens={recruiters:{},candidates:{}};
  const phase = async(name,items,fn) => {
    console.log(`\n${name} : ${items.length} éléments`);
    const problems=await parallel(items.length,opts.concurrency,fn);
    await save();
    console.log(`${name}: ${items.length-problems.length} opérations achevées ou reprises, ${problems.length} erreurs`);
    if(problems.length) {
      console.error('Premières erreurs',problems.slice(0,5));
      throw Error(`${name} incomplet : abandon de la phase suivante pour préserver la cohérence.`);
    }
  };
  await phase('Recruteurs',model.recruiters,async i=>{
    const person=model.recruiters[i],company=model.companies[person.companyIndex];
    if(!state.recruiters[i]) {
      try { const registered=await api('POST','/api/v1/recruiters/register',{body:{
        firstName:person.firstName,lastName:person.lastName,email:person.email,
        password:secret,companyName:company.name}});
        state.recruiters[i]={email:person.email,company:company.name,id:registered?.userId??null};await save();
      } catch(err) { if(err.status!==409) throw err;state.recruiters[i]={email:person.email,company:company.name,existing:true};await save(); }
    }
    const auth=await api('POST','/api/v1/auth/login',{body:{email:person.email,password:secret}});
    tokens.recruiters[i]=auth.access_token;
    if(!tokens.recruiters[i]) throw Error('Réponse de login sans access_token');
  });
  await phase('Offres',model.offers,async i=>{
    if(state.offers[i]) return;
    const modelOffer=model.offers[i];
    const token=tokens.recruiters[modelOffer.ownerIndex];
    if(!token) throw Error('Recruteur non authentifié');
    const created=await api('POST','/api/v1/recruiters/jobs',{token,body:modelOffer.body});
    if(!created?.id) throw Error('Création d’offre sans ID');
    state.offers[i]={id:created.id,title:modelOffer.body.title,status:modelOffer.body.status,
      theme:modelOffer.theme,ownerIndex:modelOffer.ownerIndex};await save();
  });
  await phase('Candidats',model.candidates,async i=>{
    const person=model.candidates[i],theme=THEMES[person.theme];
    if(!state.candidates[i]) {
      try {const registered=await api('POST','/api/v1/candidates/register',{multipart:true,body:{
        firstName:person.firstName,lastName:person.lastName,email:person.email,
        password:secret,location:person.city}});
        state.candidates[i]={id:registered?.id??null,email:person.email};await save();
      } catch(err) { if(err.status!==409) throw err;state.candidates[i]={email:person.email,existing:true};await save(); }
    }
    const auth=await api('POST','/api/v1/auth/login',{body:{email:person.email,password:secret}});
    tokens.candidates[i]=auth.access_token;
    if(!tokens.candidates[i]) throw Error('Login candidat sans access_token');
    if(!state.candidates[i].profileUpdated) {
      await api('PATCH','/api/v1/candidates/profile',{token:tokens.candidates[i],body:{
        first_name:person.firstName,last_name:person.lastName,
        headline:`Profil ${theme.title} en recherche d’opportunité`,
        location:person.city,
        bio:`Je développe mes compétences en ${theme.name.toLowerCase()}. Je souhaite contribuer à une équipe engagée, apprendre au contact de profils expérimentés et participer à des projets concrets.`,
        skills:theme.skills,
      }});
      state.candidates[i].profileUpdated=true;await save();
    }
  });
  await phase('Candidatures',model.applications,async i=>{
    if(state.applications[i]) return;
    const a=model.applications[i],offer=state.offers[a.offerIndex],token=tokens.candidates[a.candidateIndex];
    if(!offer?.id || !token) throw Error('Dépendance absente');
    const submitted=await api('POST','/api/v1/applications',{token,body:{
      jobOfferId:offer.id,
      coverMessage:`Bonjour, votre offre « ${offer.title} » m’intéresse. Je souhaite mobiliser mes compétences pour contribuer à vos projets et serais ravi d’échanger sur les missions proposées.`,
    }});
    if(!submitted?.id) throw Error('Candidature créée sans ID');
    state.applications[i]={id:submitted.id,offerId:offer.id,candidateIndex:a.candidateIndex};await save();
  });
  console.log(`\nTerminé. État de reprise : ${opts.state}`);
  console.log('Administrateurs : NON CRÉÉS (aucune route autorisée).');
}
run().catch(err=>{console.error('ARRÊT :',err.message??err);process.exitCode=1;});
