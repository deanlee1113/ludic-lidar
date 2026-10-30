// 접수 서버(Supabase) 설정. 비어 있으면 미리보기 모드(저장 안 됨)로 동작해요.
// anon key는 공개용 키라 페이지에 들어가도 돼요. 데이터 보호는 DB 보안 규칙(RLS)이 맡아요.
window.LUDIC_CONFIG = {
  supabaseUrl: "",
  supabaseAnonKey: "",
  adminEmailDomain: "nakmat.com"
};
