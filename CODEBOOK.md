# kna Master Database - Codebook

**Dataset**: `master_bills_22.parquet`
**Unit of observation**: Bill (의안)
**N**: 17,205 (22대 국회, 2024-05-30 ~ 2026-03-20)
**Variables**: 54
**Last updated**: 2026-03-30

---

## Variable Index

| # | Variable | Type | Coverage | Group |
|---|----------|------|----------|-------|
| 1 | `bill_id` | str | 100% | ID |
| 2 | `bill_no` | str | 100% | ID |
| 3 | `age` | int | 100% | ID |
| 4 | `bill_kind` | str | 100% | ID |
| 5 | `bill_nm` | str | 100% | ID |
| 6 | `ppsr_kind` | str | 100% | Proposer |
| 7 | `proposer_text` | str | 93.8% | Proposer |
| 8 | `rst_proposer` | str | 93.8% | Proposer |
| 9 | `rst_mona_cd` | str | 93.8% | Proposer |
| 10 | `publ_proposer` | str | 93.7% | Proposer |
| 11 | `publ_mona_cd` | str | 93.7% | Proposer |
| 12 | `ppsl_dt` | datetime | 100% | Lifecycle |
| 13 | `committee_dt` | datetime | 93.4% | Lifecycle |
| 14 | `bdg_cmmt_dt` | datetime | 22.4% | Lifecycle |
| 15 | `cmt_present_dt` | datetime | 75.2% | Lifecycle |
| 16 | `jrcmit_prsnt_dt` | datetime | 21.8% | Lifecycle |
| 17 | `cmt_proc_dt` | datetime | 23.6% | Lifecycle |
| 18 | `jrcmit_proc_dt` | datetime | 21.9% | Lifecycle |
| 19 | `law_submit_dt` | datetime | 3.0% | Lifecycle |
| 20 | `law_present_dt` | datetime | 2.7% | Lifecycle |
| 21 | `law_proc_dt` | datetime | 2.7% | Lifecycle |
| 22 | `proc_dt` | datetime | 21.3% | Lifecycle |
| 23 | `jrcmit_proc_rslt` | str | 22.4% | Result |
| 24 | `cmt_proc_result_cd` | str | 24.1% | Result |
| 25 | `law_proc_result_cd` | str | 2.7% | Result |
| 26 | `proc_rslt` | str | 27.5% | Result |
| 27 | `status` | str | 100% | Result |
| 28 | `passed` | int | 100% | Result |
| 29 | `enacted` | int | 100% | Result |
| 30 | `vote_result_cd` | str | 7.2% | Vote |
| 31 | `vote_member_total` | float | 7.2% | Vote |
| 32 | `vote_total` | float | 7.2% | Vote |
| 33 | `vote_yes` | float | 7.2% | Vote |
| 34 | `vote_no` | float | 7.2% | Vote |
| 35 | `vote_abstain` | float | 7.2% | Vote |
| 36 | `committee_nm` | str | 93.4% | Committee |
| 37 | `committee_id` | str | 93.4% | Committee |
| 38 | `jrcmit_nm` | str | 22.4% | Committee |
| 39 | `link_url` | str | 100% | Meta |
| 40 | `member_list` | str | 93.8% | Meta |
| 41 | `days_to_proc` | float | 21.3% | Derived |
| 42 | `days_to_committee` | float | 22.4% | Derived |
| 43 | `jrcmit_cmmt_dt` | datetime | 22.4% | Lifecycle (Phase 2) |
| 44 | `law_cmmt_dt` | datetime | 2.7% | Lifecycle (Phase 2) |
| 45 | `law_prsnt_dt` | datetime | 2.7% | Lifecycle (Phase 2) |
| 46 | `law_proc_rslt` | str | 2.7% | Result (Phase 2) |
| 47 | `rgs_prsnt_dt` | datetime | 7.2% | Lifecycle (Phase 2) |
| 48 | `rgs_rsln_dt` | datetime | 7.2% | Lifecycle (Phase 2) |
| 49 | `rgs_conf_nm` | str | 7.2% | Result (Phase 2) |
| 50 | `rgs_conf_rslt` | str | 7.2% | Result (Phase 2) |
| 51 | `gvrn_trsf_dt` | datetime | 2.6% | Lifecycle (Phase 2) |
| 52 | `prom_dt` | datetime | 2.6% | Lifecycle (Phase 2) |
| 53 | `prom_no` | str | 2.6% | Meta (Phase 2) |
| 54 | `prom_law_nm` | str | 2.6% | Meta (Phase 2) |

---

## Detailed Variable Descriptions

### Group 1: Identifiers

#### `bill_id`
- **Description**: 법안 고유 식별자 (Primary Key)
- **Type**: `str` (object)
- **Format**: `PRC_` + 30-char alphanumeric / `ARC_` + 30-char alphanumeric
- **Example**: `PRC_Y2Z6X0Y2F1G3E1D1D1B1C2Y6Y0W6X6`
- **Length**: 34 characters (fixed)
- **Unique**: 17,205 (100%)
- **Null**: 0
- **Notes**: `PRC_` prefix for most bills (87,871 in BILLRCP); `ARC_` prefix for some older/special bills (4,650 in BILLRCP). Some non-standard IDs exist in historical data (4-digit numeric prefix). This is the master join key across all tables.

#### `bill_no`
- **Description**: 의안 번호
- **Type**: `str` (object)
- **Format**: 7-digit numeric string
- **Example**: `2217673`
- **Unique**: 17,197
- **Near-unique**: 8 duplicate bill_no values exist (대안 등으로 동일 번호 부여 가능)
- **Null**: 0
- **Notes**: 일반적으로 unique하지만 BILL_ID를 primary key로 사용해야 함. 첫 두 자리 `22`는 22대를 의미.

#### `age`
- **Description**: 국회 대수
- **Type**: `int64`
- **Values**: 22 (현재 데이터셋)
- **Null**: 0
- **Notes**: 확장 시 17~22 범위. 22대 = 2024.5.30 임기 시작.

#### `bill_kind`
- **Description**: 의안 유형
- **Type**: `str` (object)
- **Values** (9 categories):

| Value | N | % | Description |
|-------|---|---|-------------|
| 법률안 | 16,907 | 98.3% | 법률 제정/개정안 (핵심 분석 대상) |
| 결의안 | 112 | 0.7% | 국회 의사 표명 (법적 구속력 없음) |
| 동의안 | 54 | 0.3% | 헌법/법률에 따른 동의 요청 |
| 예산안 | 41 | 0.2% | 정부 예산안 |
| 중요동의 | 35 | 0.2% | 국군 해외파견 등 중요 동의 |
| 승인안 | 32 | 0.2% | 조약 비준 동의 등 |
| 선출안 | 20 | 0.1% | 인사 선출 |
| 규칙안 | 2 | <0.1% | 국회 규칙 |
| 결산 | 2 | <0.1% | 결산 심사 |

- **Null**: 0
- **Notes**: 대부분 연구에서는 `bill_kind == '법률안'`으로 필터링하여 사용.

#### `bill_nm`
- **Description**: 법안명 (의안 제목)
- **Type**: `str` (object)
- **Example**: `약사법 일부개정법률안`, `국민연금법 일부개정법률안`
- **Unique**: 2,984 (같은 법률에 대한 여러 개정안은 동일 이름)
- **Length**: 4~105 characters
- **Null**: 0
- **Notes**: 같은 법률에 대해 여러 의원이 개정안을 제출하므로 중복됨. 조세특례제한법이 661건으로 최다. NLP 분석 시 법률명 + 개정 내용 구분 필요.

---

### Group 2: Proposer Information

#### `ppsr_kind`
- **Description**: 발의/제안 주체 유형
- **Type**: `str` (object)
- **Values** (5 categories):

| Value | N | % | Description |
|-------|---|---|-------------|
| 의원 | 16,231 | 94.3% | 국회의원 발의 (대표발의자 + 공동발의자) |
| 위원장 | 635 | 3.7% | 상임위원회 위원장 제안 (대안, 위원회안) |
| 정부 | 294 | 1.7% | 정부 제출 법안 |
| 의장 | 41 | 0.2% | 국회의장 제안 (예산안 등) |
| 기타 | 4 | <0.1% | 기타 |

- **Null**: 0
- **Notes**: 의원 발의만 `rst_proposer`, `rst_mona_cd` 등 상세 발의자 정보 보유. 위원장/정부/의장 발의는 해당 필드가 null.

#### `proposer_text`
- **Description**: 발의자 전체 텍스트
- **Type**: `str` (object)
- **Example**: `김종민의원 등 10인`, `민형배의원 등 10인`
- **Format**: `{이름}의원 등 {N}인`
- **Length**: 10~24 characters
- **Null**: 1,063 (6.2%) - 의원 발의가 아닌 법안
- **Notes**: 공동발의자 수는 이 텍스트에서 정규식으로 추출 가능: `(\d+)인$`. 대표발의자 이름도 포함.

#### `rst_proposer`
- **Description**: 대표발의자 이름
- **Type**: `str` (object)
- **Example**: `김종민`, `윤준병`, `추미애`
- **Unique**: 421 (22대 국회의원 중 법안 발의자)
- **Length**: 2~11 characters
- **Null**: 1,063 (의원 발의가 아닌 법안)
- **Notes**: 22대 국회의원 300명 중 법안을 1건 이상 대표발의한 의원 수. 다른 프로젝트와 연결 시 `rst_mona_cd`를 사용해야 함 (이름 동명이인 존재 가능).

#### `rst_mona_cd`
- **Description**: 대표발의자 의원 코드 (MONA_CD)
- **Type**: `str` (object)
- **Format**: 8-character alphanumeric (일반적), 일부 더 긴 코드 존재
- **Example**: `M2Q9024I`, `JC14718Q`
- **Unique**: 421
- **Length**: 8~26 characters
- **Null**: 1,063
- **Notes**: **핵심 조인 키**. 다른 프로젝트(committee-witnesses-korea의 `naas_cd`, legislator-assets-korea 등)와 의원 단위 연결에 사용. 열린국회정보 의원 API에서 의원 메타데이터(정당, 지역구, 선수 등) 매칭 가능.

#### `publ_proposer`
- **Description**: 공동발의자 이름 목록
- **Type**: `str` (object)
- **Format**: 쉼표 구분 이름 목록
- **Example**: `허성무,최혁진,손솔,한창민,윤종오,김승원,전종덕,안호영,황운하`
- **Length**: 30~756 characters
- **Unique**: 13,894
- **Null**: 1,085
- **Notes**: Cosponsorship 네트워크 구축 시 파싱 필요. 이름만 포함 (코드 없음). 코드가 필요하면 `publ_mona_cd` 사용.

#### `publ_mona_cd`
- **Description**: 공동발의자 의원 코드 목록
- **Type**: `str` (object)
- **Format**: 쉼표 구분 MONA_CD 목록
- **Example**: `HHB5652A,CC78321E,2KM3589W,...`
- **Length**: 71~1,709 characters
- **Unique**: 13,894
- **Null**: 1,085
- **Notes**: `publ_proposer`와 1:1 대응 (같은 순서). 네트워크 분석 시 이 필드를 파싱하여 edge list 생성 가능. `member_list` URL을 크롤링하면 더 정확한 데이터 확보 가능.

---

### Group 3: Lifecycle Timestamps

모든 날짜는 `datetime64[ns]` 타입. 법안이 해당 단계에 도달하지 않은 경우 `NaT` (Not a Time).

#### `ppsl_dt` (발의일/제출일)
- **Coverage**: 100% (17,205)
- **Range**: 2024-05-30 ~ 2026-03-20
- **Notes**: 모든 법안의 시작점. 22대 국회 개원일은 2024-05-30.

#### `committee_dt` (소관위원회 회부일)
- **Source**: nzmimeepazxkubdpn `COMMITTEE_DT`
- **Coverage**: 93.4% (16,071)
- **Range**: 2024-06-11 ~ 2026-03-20
- **Null reason**: 발의 직후 아직 회부되지 않았거나, 비의원발의 법안
- **Notes**: 발의 후 회부까지 중위 1일, 평균 3.6일. 거의 자동적으로 회부됨.

#### `bdg_cmmt_dt` (소관위 회부일 - BILLJUDGE 소스)
- **Source**: BILLJUDGE `BDG_CMMT_DT`
- **Coverage**: 22.4% (3,859)
- **Notes**: BILLJUDGE 데이터의 소관위 회부일. `committee_dt`와 유사하나 다른 API 소스. BILLJUDGE에 데이터가 있는 법안만 해당 (22대 3,859건).

#### `cmt_present_dt` (위원회 상정일)
- **Source**: nzmimeepazxkubdpn `CMT_PRESENT_DT`
- **Coverage**: 75.2% (12,935)
- **Range**: 2024-06-12 ~ 2026-03-19
- **Notes**: 소관위원회에서 안건으로 상정된 날짜. 회부와 상정은 다름 - 회부는 행정적 배분, 상정은 실질적 심사 개시.

#### `jrcmit_prsnt_dt` (소관위 상정일 - BILLJUDGE 소스)
- **Source**: BILLJUDGE `JRCMIT_PRSNT_DT`
- **Coverage**: 21.8% (3,759)
- **Notes**: BILLJUDGE의 소관위 상정일. `cmt_present_dt`와 동일 의미, 다른 소스.

#### `cmt_proc_dt` (소관위 처리일)
- **Source**: nzmimeepazxkubdpn `CMT_PROC_DT`
- **Coverage**: 23.6% (4,060)
- **Range**: 2024-06-18 ~ 2026-03-18
- **Notes**: 소관위에서 최종 처리(가결/폐기 등)된 날짜.

#### `jrcmit_proc_dt` (소관위 처리일 - BILLJUDGE 소스)
- **Source**: BILLJUDGE `JRCMIT_PROC_DT`
- **Coverage**: 21.9% (3,761)
- **Notes**: BILLJUDGE의 소관위 처리일.

#### `law_submit_dt` (법사위 회부일)
- **Source**: nzmimeepazxkubdpn `LAW_SUBMIT_DT`
- **Coverage**: 3.0% (510)
- **Range**: 2024-06-18 ~ 2026-03-17
- **Notes**: 소관위를 통과한 법안 중 법사위(법제사법위원회)에 회부된 법안만. 법사위는 체계/자구 심사를 담당. 매우 낮은 coverage는 대부분의 법안이 이 단계에 도달하지 못함을 의미.

#### `law_present_dt` (법사위 상정일)
- **Source**: nzmimeepazxkubdpn `LAW_PRESENT_DT`
- **Coverage**: 2.7% (464)
- **Notes**: 법사위에서 안건 상정. `law_submit_dt`보다 약간 적음 (회부 후 아직 상정되지 않은 법안 존재).

#### `law_proc_dt` (법사위 처리일)
- **Source**: nzmimeepazxkubdpn `LAW_PROC_DT`
- **Coverage**: 2.7% (459)
- **Notes**: 법사위 심사 완료일.

#### `proc_dt` (최종 처리일)
- **Source**: nzmimeepazxkubdpn `PROC_DT`
- **Coverage**: 21.3% (3,664)
- **Range**: 2024-06-10 ~ 2026-03-20
- **Notes**: 법안의 최종 처리 완료일. 원안가결/수정가결/폐기/철회 등 최종 상태가 결정된 날짜. `days_to_proc` 계산에 사용.

#### Phase 2 필드 (BILLINFODETAIL)

Phase 2 수집 완료. 다음 필드는 Variable Index #43-54에 포함되어 있습니다:

| 필드 | 설명 |
|------|------|
| `jrcmit_cmmt_dt` | 소관위 회부일 (BILLINFODETAIL 소스, 가장 정확) |
| `law_cmmt_dt` | 법사위 회부일 (BILLINFODETAIL) |
| `law_prsnt_dt` | 법사위 상정일 (BILLINFODETAIL) |
| `law_proc_rslt` | 법사위 처리결과 |
| `rgs_prsnt_dt` | 본회의 상정일 |
| `rgs_rsln_dt` | 본회의 의결일 |
| `rgs_conf_nm` | 본회의 회차 |
| `rgs_conf_rslt` | 본회의 결과 |
| `gvrn_trsf_dt` | 정부이송일 |
| `prom_dt` | 공포일 |
| `prom_no` | 공포번호 |
| `prom_law_nm` | 공포법률명 |

---

### Group 4: Processing Results

#### `jrcmit_proc_rslt` (소관위 처리결과)
- **Source**: BILLJUDGE
- **Coverage**: 22.4% (3,859)
- **Values** (11 categories):

| Value | N | Description |
|-------|---|-------------|
| 대안반영폐기 | 3,101 | 법안 내용이 위원장 대안에 반영된 후 폐기 |
| 수정가결 | 376 | 수정을 거쳐 가결 |
| 원안가결 | 212 | 원안 그대로 가결 |
| 철회 | 114 | 발의자가 자진 철회 |
| 수정안반영폐기 | 39 | 수정안에 내용 반영 후 폐기 |
| 부결 | 5 | 위원회에서 부결 |
| 폐기 | 5 | 위원회에서 폐기 결정 |
| 보류 | 3 | 심사 보류 |
| 철수 | 2 | 철수 |
| 임기만료폐기 | 1 | 임기 만료로 자동 폐기 |
| 수정안가결 | 1 | 수정안 형태로 가결 |

#### `cmt_proc_result_cd` (소관위 처리결과 - 코드)
- **Source**: nzmimeepazxkubdpn/nzpltgfqabtcpsmai
- **Coverage**: 24.1% (4,153)
- **Notes**: `jrcmit_proc_rslt`와 유사하나 다른 API 소스. 약간의 분류 차이 있을 수 있음.

#### `law_proc_result_cd` (법사위 처리결과)
- **Coverage**: 2.7% (459)
- **Values**: 수정가결 (264), 원안가결 (195)
- **Notes**: 법사위까지 도달한 법안은 거의 가결됨 (부결 없음).

#### `proc_rslt` (최종 처리결과)
- **Coverage**: 27.5% (4,727)
- **Values**:

| Value | N | Description |
|-------|---|-------------|
| 대안반영폐기 | 3,101 | 내용이 대안에 반영되어 실질적 "통과" |
| 원안가결 | 977 | 원안 그대로 최종 가결 → 법률 |
| 수정가결 | 422 | 수정 후 최종 가결 → 법률 |
| 철회 | 146 | 발의자 자진 철회 |
| 수정안반영폐기 | 39 | 수정안에 반영 후 폐기 |
| 부결 | 33 | 최종 부결 |
| 폐기 | 9 | 최종 폐기 |

- **Null**: 12,478 (72.5%) - 아직 처리되지 않은 계류 법안

#### `status` (현재 상태)
- **Coverage**: 100%
- **Values**: `proc_rslt`의 값 + "계류중" (proc_rslt이 null인 경우)
- **Derivation**: `proc_rslt.fillna("계류중")`
- **Notes**: 분석에서 가장 자주 사용할 상태 변수.

#### `passed` (통과 여부 - 넓은 정의)
- **Type**: `int64` (binary: 0/1)
- **Coverage**: 100%
- **Values**: 0 = 미통과 (12,705), 1 = 통과 (4,500)
- **Definition**: `proc_rslt in ['원안가결', '수정가결', '대안반영폐기']`
- **Notes**: "대안반영폐기"를 통과로 포함. 법안 내용이 다른 법안(주로 위원장 대안)에 반영된 것이므로 실질적 입법 기여로 간주. 한국 국회의 관행상 의원 발의 법안은 위원장 대안에 병합되는 것이 일반적.

#### `enacted` (가결 여부 - 좁은 정의)
- **Type**: `int64` (binary: 0/1)
- **Coverage**: 100%
- **Values**: 0 = 미가결 (15,806), 1 = 가결 (1,399)
- **Definition**: `proc_rslt in ['원안가결', '수정가결']`
- **Notes**: 해당 법안 자체가 법률로 확정된 경우만. 대안반영폐기 제외. 연구 설계에 따라 `passed`와 `enacted` 중 선택.

---

### Group 5: Vote Details

본회의 표결에 부쳐진 법안만 해당 (N = 1,236, 전체의 7.2%). 대부분의 법안은 표결 없이 처리됨 (위원회 단계에서 종료되거나, 본회의에서 이의 없이 통과).

#### `vote_result_cd` (표결 결과)
- **Values**: 원안가결 (843), 수정가결 (391), 부결 (2)

#### `vote_member_total` (재적의원수)
- **Range**: 295~300
- **Notes**: 22대 의원 정수 300명. 사직/보궐 등으로 변동.

#### `vote_total` (투표 참여 의원수)
- **Range**: 150~297 (mean: 230.4, median: 238)

#### `vote_yes` (찬성)
- **Range**: 75~297 (mean: 222.5, median: 229)

#### `vote_no` (반대)
- **Range**: 0~181 (mean: 4.0, median: 0)
- **Notes**: 대부분의 표결에서 반대 0. 중위수 0은 만장일치 투표가 지배적임을 의미.

#### `vote_abstain` (기권)
- **Range**: 0~44 (mean: 3.9, median: 2)

---

### Group 6: Committee Information

#### `committee_nm` (소관위원회 이름)
- **Coverage**: 93.4% (16,068)
- **Unique**: 25 committees
- **Top 5**: 행정안전위원회(2,117), 법제사법위원회(1,519), 기후에너지환경노동위원회(1,406), 국토교통위원회(1,374), 보건복지위원회(1,364)
- **Null reason**: 비의원발의 법안 중 위원회 미배정 건

#### `committee_id` (소관위원회 코드)
- **Coverage**: 93.4% (16,068)
- **Format**: 7-digit numeric string (e.g., `9700480`)
- **Notes**: `committee_nm`과 1:1 대응. 위원회 코드로 조인 시 사용.

#### `jrcmit_nm` (소관위 - BILLJUDGE 소스)
- **Coverage**: 22.4% (3,858)
- **Unique**: 30 (위원회 명칭 변경 반영)
- **Notes**: BILLJUDGE에서의 소관위 이름. `committee_nm`과 약간의 명칭 차이 가능 (22대 위원회 개편 반영 여부 차이).

---

### Group 7: Metadata

#### `link_url` (LIKMS 상세 페이지)
- **Coverage**: 100%
- **Format**: `http://likms.assembly.go.kr/bill/billDetail.do?billId={BILL_ID}&ageFrom=22&ageTo=22`
- **Notes**: 국회 입법정보시스템 상세 페이지. 법안 원문(PDF), 심사 경과, 회의록 링크 등 확인 가능. 법안 원문 크롤링의 진입점.

#### `member_list` (공동발의자 목록 URL)
- **Coverage**: 93.8% (16,142)
- **Format**: `http://likms.assembly.go.kr/bill/coactorListPopup.do?billId={BILL_ID}`
- **Notes**: 크롤링하면 공동발의자 상세 정보(이름, 정당, 선수 등) 획득 가능. Cosponsorship 네트워크 구축의 원천 데이터.

---

### Group 8: Derived Variables

#### `days_to_proc` (발의~처리 소요일)
- **Coverage**: 21.3% (3,664) - 처리 완료된 법안만
- **Derivation**: `(proc_dt - ppsl_dt).days`
- **Distribution**: min 0, Q1 99, median 171, mean 210, Q3 290, max 645
- **Unit**: Days
- **Notes**: 0일은 발의 당일 처리 (주로 위원장안). 645일은 22대 초기 발의 후 최근 처리된 법안.

#### `days_to_committee` (발의~소관위 회부 소요일)
- **Coverage**: 22.4% (3,859)
- **Derivation**: `(bdg_cmmt_dt - ppsl_dt).days`
- **Distribution**: min 0, Q1 0, median 1, mean 3.6, max 495
- **Unit**: Days
- **Notes**: 중위 1일로 거의 자동적 회부. 495일 이상 소요는 극단적 예외.

---

## Satellite Tables

### `committee_meetings` (위원회 회의정보)

**Source**: BILLJUDGECONF
**Unit**: Bill-Meeting (1 bill = N meetings)
**Rows**: 572,127 (17-22대)

| Variable | Type | Description |
|----------|------|-------------|
| `bill_id` | str | 법안 ID (FK → bills) |
| `jrcmit_conf_nm` | str | 회의명 (예: "제419회 국회 보건복지위원회") |
| `jrcmit_conf_dt` | str | 회의 날짜 |
| `jrcmit_conf_rslt` | str | 회의 결과 (상정, 소위심사보고, 축조심사, 의결 등) |

### `judiciary_meetings` (법사위 회의정보)

**Source**: BILLLWJUDGECONF
**Unit**: Bill-Meeting (1 bill = N meetings)
**Rows**: 15,325 (17-22대)

| Variable | Type | Description |
|----------|------|-------------|
| `bill_id` | str | 법안 ID (FK → bills) |
| `lwcmit_conf_nm` | str | 법사위 회의명 |
| `lwcmit_conf_dt` | str | 법사위 회의 날짜 |
| `lwcmit_conf_rslt` | str | 법사위 회의 결과 |

---

## Ideal Points (이상점)

본 저장소는 **세 가지 이상점 계열**을 제공한다. 셋은 서로 다른 질문에 답하며
**교체 가능하지 않다**. 생성 스크립트는 `build_ideal_points.R` 하나다.

| 파일 | 컬럼 | 방법 | 대수 내 비교 | 대수 간 비교 | 의원 이동 |
|------|------|------|:---:|:---:|:---:|
| `ideal_points_wnominate.csv` | `wnom_1d` | 대수별 W-NOMINATE (1차원 적합) | ✅ | ❌ | ❌ |
| `ideal_points_bridged.csv` | `bridged_1d` | 연쇄 bridging 정렬 | ✅ | ✅ | ⚠️ 부분적 |
| `ideal_points_dwnominate.csv` | `dwnom_1d` | 통합 DW-NOMINATE | ✅ | ✅ | ❌ (상수) |

공통 컬럼: `member_id` (MONA_CD), `member_name`, `party`, `term`.
부호 규약: **양수 = 보수, 음수 = 진보** (Voteview 표준, 세 계열 모두 통일).

### 1. `ideal_points_wnominate.csv` - 대수별 W-NOMINATE

각 대수를 독립적으로 스케일링한다. **`wnom_1d`는 1차원 적합의 좌표다.**
2차원 적합도 함께 수행하며 그 좌표는 `wnom2d_dim1`, `wnom2d_dim2`로 제공된다
(차원수 진단의 고유값도 2차원 적합에서 나온다). 이 파일이 쓰이는 모든 양,
즉 정당 간 거리·당내 분산·그 비율이 단일 차원에서 정의되므로 1차원 적합을
기본으로 삼는다. 2차원 해의 첫 좌표를 쓰면 회전 문제가 따라온다. 표본은 소수파 비율 2.5% 이상인 표결(contested)과
그런 표결에 20회 이상 참여한 의원으로 제한된다.

**⚠️ 대수 간 비교 금지.** 스케일링 모형은 의원 배치를 **반사(reflection)와 정규화까지만**
식별한다. 축의 부호가 임의이고, 각 대수가 같은 유계 공간으로 재정규화된다. 따라서
`wnom_1d[t=22] - wnom_1d[t=20]`은 실제 이동과 척도 재설정이 섞인 해석 불가능한 양이다.

이 파일에서는 보수 정당 평균이 음수가 되도록 대수마다 부호를 맞춰 두었으므로 부호 문제는
해소되어 있으나, **재정규화 문제는 남는다**.

### 2. `ideal_points_bridged.csv` - 연쇄 bridging 정렬

두 대수 모두에 재직한 의원(bridging legislators)을 이용해 이후 대수를 이전 대수의 단위로
사상(map)한다. 20대를 기준으로 21대를 정렬하고, 정렬된 21대를 기준으로 22대를 정렬한다.

```
bridged_1d[t] = intercept_t + slope_t * wnom_1d[t]
```

적합 계수는 `ideal_points_bridging_params.csv`에 기록된다 (21대 n=126, 22대 n=150).

**가정**: bridging 의원들이 평균적으로 이동하지 않는다고 본다. 실제로 이동했다면 그 이동이
사상(mapping)에 흡수된다. 이 한계를 감수하면 대수 간 비교가 가능하고, 의원별 대수별 변화도
보존되므로 시계열 시각화에 적합하다. **본 저장소의 기본 계열이다.**

### 3. `ideal_points_dwnominate.csv` - 통합 DW-NOMINATE

세 대수를 함께 추정하며 bridging 의원이 단일 척도를 정박한다. 학술적으로 가장 정통이다.

**⚠️ 구조적 제약**: `dwnominate`는 의원 궤적을 대수 지수의 다항식으로 표현하는데,
**선형 궤적조차 최소 5개 회기가 필요**하다. 3개 대수뿐이므로 상수항만 추정 가능하고,
따라서 **각 의원은 전 기간 단일 값**을 갖는다. 정당 평균의 대수 간 변화는 전적으로
구성(교체) 효과다. 의원 개인의 이동 분석에는 사용할 수 없다.

### 세 계열의 비교

양대 정당 평균 간 거리:

| 대수 | 대수별 W-NOM | bridged | 통합 DW-NOM |
|------|-------------|---------|------------|
| 20대 | 0.753 | 0.753 | 0.710 |
| 21대 | 0.903 | 0.806 | 0.772 |
| 22대 | 1.243 | 0.801 | 0.794 |
| **20→22 증가율** | **+65.0%** | **+6.3%** | **+12.0%** |

당내 분산(정당 결속의 역수):

| 대수 | 대수별 W-NOM | bridged | 통합 DW-NOM |
|------|-------------|---------|------------|
| 20대 | 0.186 | 0.186 | 0.133 |
| 22대 | 0.080 | 0.052 | 0.099 |

**중요**: 스케일링 모형은 척도를 복원된 배치 자체에서 정하므로, 식별되는 양은 정당 간
거리가 아니라 **거리/당내분산 비율**이다. 따라서 정당이 결속하면(당내 분산 감소) 위치가
그대로여도 거리가 늘어난 것으로 기록된다. 실제로 이 기간 한국 정당의 단결도는
0.911 → 0.943으로 상승했다(스케일링 무관 지표).

**bridging으로는 교정되지 않는다.** 아파인 변환은 거리와 분산을 같은 배수로 바꾸므로
비율을 보존한다. 위 표에서 대수별과 bridged의 거리/분산 비율은 매 대수 동일하다
(4.05, 5.31, 15.49). 통합 DW-NOMINATE만 척도를 챔버 밖에서 정박하므로 비율이 다르다
(5.33, 6.26, 8.04).

**따라서**: 대수 간 양극화 추세를 논할 때는 (a) 거리와 함께 당내 분산을 반드시 보고하고,
(b) 대수별 계열의 증가폭을 상한으로 취급할 것.

### 데이터 제약

- **20대 이후만 제공**. 열린국회정보 API는 20대부터 의원별 표결을 공개한다.
  16-19대 기록은 `roll_calls_all.parquet`에 일부 있으나 `member_id`/`bill_id`가
  결측이라 표결 행렬을 구성할 수 없다.
- 22대는 회기 중이며 값은 잠정적이다.
- 정당 라벨은 API가 소급 부여한다(각 의원의 최근 정당). 대수 간 당적 변경은
  표결 데이터만으로는 직접 관측되지 않는다.

### `dw_ideal_points_20_22.csv` (deprecated)

이전 배포판의 이 파일은 DW-NOMINATE로 라벨링되었으나 실제로는 대수별 W-NOMINATE에
부호를 맞춘 것이었다(`coord1D`). `aligned` 컬럼은 위 2번과 같은 연쇄 bridging 정렬이었으나
문서화되지 않았다. 상세는 `CORRECTIONS.md` 참조. 신규 작업에는 위 세 파일을 사용할 것.

---

## Coverage Notes

### 왜 많은 필드가 낮은 coverage인가?

22대 국회는 현재 **진행 중** (2024.5 ~ 현재). 17,205건 중 12,478건(72.5%)이 아직 계류 상태.

| 단계 | 도달 법안 수 | 전체 대비 |
|------|------------|----------|
| 발의 | 17,205 | 100% |
| 소관위 회부 | ~16,071 | 93.4% |
| 소관위 상정 | ~12,935 | 75.2% |
| 소관위 처리 | ~4,060 | 23.6% |
| 법사위 회부 | ~510 | 3.0% |
| 법사위 처리 | ~459 | 2.7% |
| 본회의 표결 | ~1,236 | 7.2% |
| 최종 처리 | ~4,727 | 27.5% |

이 "깔때기" 구조 자체가 연구 대상임 - 법안이 어느 단계에서 사라지는지.

### 중복 날짜 필드 설명

일부 날짜가 여러 API 소스에서 중복 수집됨:
- `committee_dt` (nzmimeepazxkubdpn) vs `bdg_cmmt_dt` (BILLJUDGE)
- `cmt_present_dt` (nzmimeepazxkubdpn) vs `jrcmit_prsnt_dt` (BILLJUDGE)
- `cmt_proc_dt` (nzmimeepazxkubdpn) vs `jrcmit_proc_dt` (BILLJUDGE)

nzmimeepazxkubdpn이 의원 발의 법안 전체를 커버(16,142건)하고, BILLJUDGE는 처리된 법안 위주(3,859건). 둘 다 보유하여 cross-validation 가능.

Phase 2의 BILLINFODETAIL은 가장 포괄적인 lifecycle 데이터를 제공하며, 전 대수 수집 완료(2026-03-26).

---

## Cross-Project Join Keys

| This DB | Other Project | Join Key | Notes |
|---------|---------------|----------|-------|
| `rst_mona_cd` | committee-witnesses-korea (`naas_cd`) | 의원 코드 | 형식 확인 필요 |
| `rst_mona_cd` | legislator-assets-korea | 의원 코드 | 발의 행태 + 자산 연결 |
| `bill_id` | na-legislative-events-korea | 법안 ID | 동일 소스, 직접 조인 |
| `rst_proposer` | korean-politics-youtube (`HG_NM`) | 의원 이름 | 동명이인 주의, 코드 선호 |
| `committee_nm` | committee-witnesses-korea | 위원회명 | harmonization 필요 |
