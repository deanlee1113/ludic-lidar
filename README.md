# 루딕 라이다 사전예약

작약꽃 × 루딕 라이다 라이브 네고 딜 사전예약 페이지와 관리자 페이지예요. GitHub Pages로 띄우고, 신청·방문 기록은 Supabase에 저장해요.

## 구성

| 경로 | 내용 |
|---|---|
| `index.html` | 사전예약 페이지 (STRIKE LiDAR: 검정 + 루딕 퍼플 + 글라스) |
| `admin/index.html` | 관리자 페이지: 방문·순방문자·사전예약·전환율, 단계별 이탈, 일별 추이, 모델별 수량, 유입 경로, 기기, 신청자 목록(검색·CSV·삭제) |
| `config.js` | Supabase 주소와 공개(anon) 키. 비어 있으면 미리보기 모드로 동작해요 |
| `supabase/schema.sql` | 테이블, 보안 규칙(RLS), 신청·이벤트·통계 함수 |
| `assets/logo-white.webp` | 낚맛 흰색 로고 |

## 규칙

- 사전예약은 휴대폰 번호 1개당 1건이에요.
- 모델 상관없이 1인당 합계 1~3개까지 신청할 수 있어요. 페이지와 DB 양쪽에서 막아요.
- 방문자는 테이블을 직접 읽거나 쓸 수 없어요. 신청 함수와 이벤트 기록 함수만 호출할 수 있어요.
- 신청 내용 조회·삭제와 통계는 `admins` 테이블에 등록된 로그인 계정만 볼 수 있어요.
- 방문 기록은 기기별 임의 ID, 유입 경로(utm_source 또는 이전 사이트), 기기 종류만 남겨요. IP는 저장하지 않아요.

## 설정 순서

1. Supabase 프로젝트에서 `supabase/schema.sql`을 실행해요.
2. Authentication에서 관리자 사용자를 만들어요. 이메일 확인은 바로 완료 처리해요.
3. 그 사용자를 관리자로 등록해요.
   ```sql
   insert into public.admins (user_id)
   select id from auth.users where email = '관리자 이메일';
   ```
4. Authentication 설정에서 새 사용자 가입을 꺼요.
5. `config.js`에 프로젝트 URL과 anon 키를 넣어요.

관리자 페이지 아이디 칸에 `@` 없이 입력하면 `아이디@` 뒤에 `config.js`의 `adminEmailDomain`을 붙여 로그인해요.

## 유입 경로 붙이기

링크 뒤에 `?utm_source=이름`을 붙이면 관리자 페이지의 유입 경로에 그 이름으로 잡혀요. 예: `?utm_source=instagram`, `?utm_source=kakao`.
