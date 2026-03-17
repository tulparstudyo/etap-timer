/**
 * kurumlar.json dosyasını institutions tablosuna aktarır.
 * Kullanım: node import-json.js ../kurumlar.json
 *
 * JSON yapısı: { IL_ADI: { ILCE_ADI: [ { OKUL_ADI, YOL, CONTACT: { PHONE }, WEBSITE, ... } ] } }
 * YOL formatı: il_kodu/ilce_kodu/institution_code
 */
const fs = require('fs');
const { pool, migrate, checkConnection } = require('./helper');

const JSON_PATH = process.argv[2] || '../kurumlar.json';
const BATCH_SIZE = 500;

async function run() {
  await checkConnection();
  await migrate();

  console.log(`[Import] Dosya okunuyor: ${JSON_PATH}`);
  const raw = fs.readFileSync(JSON_PATH, 'utf-8');
  console.log('[Import] JSON parse ediliyor...');
  const data = JSON.parse(raw);

  const rows = [];
  const usedCodes = new Set();

  // Önce tüm kayıtları topla
  let count = 0;
  const iller = Object.keys(data);
  console.log(`[Parse] ${iller.length} il bulundu.`);

  for (const [ilAdi, ilceler] of Object.entries(data)) {
    const ilceCount = Object.keys(ilceler).length;
    console.log(`[Parse] ${ilAdi} (${ilceCount} ilçe) işleniyor...`);

    for (const [ilceAdi, okullar] of Object.entries(ilceler)) {
      if (!Array.isArray(okullar)) continue;

      for (const okul of okullar) {
        count++;

        const name = (okul.OKUL_ADI || '').trim();
        if (!name) continue;

        const yolParts = (okul.YOL || '').split('/');
        const ilKodu = yolParts[0] || null;
        const ilceKodu = yolParts[1] || null;
        const institutionCode = yolParts[2] || null;

        if (!institutionCode || usedCodes.has(institutionCode)) continue;
        usedCodes.add(institutionCode);

        const phone = (okul.CONTACT?.PHONE || '').trim() || '-';
        const website = (okul.WEBSITE || '').trim() || null;
        const emailLink = (okul.CONTACT?.EMAIL_LINK || '').trim() || null;

        rows.push({
          name, institutionCode, phone, ilAdi, ilKodu, ilceAdi, ilceKodu, website, emailLink
        });
      }
    }
  }
  console.log(`\r[Parse] Toplam taranan: ${count}`);

  console.log(`[Import] ${rows.length} kayıt bulundu.`);

  // Satırları SQL formatına çevir (şifre null — kurum ilk girişte belirleyecek)
  const sqlRows = rows.map(r => [
    r.name,
    r.institutionCode,
    null,
    '-',
    r.phone,
    'Türkiye',
    r.ilAdi,
    r.ilKodu,
    r.ilceAdi,
    r.ilceKodu,
    'MEB',
    r.website,
    r.emailLink
  ]);

  console.log(`[Import] Toplam kayıt: ${sqlRows.length}`);

  const sql = `INSERT IGNORE INTO institutions
    (name, institution_code, password, responsible_name, phone,
     ulke_adi, il_adi, il_kodu, ilce_adi, ilce_kodu, tip, website, email_link)
    VALUES ?`;

  let inserted = 0;
  for (let i = 0; i < sqlRows.length; i += BATCH_SIZE) {
    const batch = sqlRows.slice(i, i + BATCH_SIZE);
    try {
      const [result] = await pool.query(sql, [batch]);
      inserted += result.affectedRows;
      console.log(`[Import] ${Math.min(i + BATCH_SIZE, sqlRows.length)}/${sqlRows.length} işlendi (${result.affectedRows} eklendi)`);
    } catch (err) {
      console.error(`[Import] Batch hatası (satır ${i}):`, err.message);
    }
  }

  console.log(`[Import] Tamamlandı. Toplam eklenen: ${inserted}`);
  process.exit(0);
}

run().catch(err => {
  console.error('[Import] Hata:', err.message);
  process.exit(1);
});
