% if 'logo' in cfg.tt:
%   for logo_name, logo_desc in cfg.tt.logo.items():
	(* blackbox, keep *)
	${logo_name} ${logo_name}_I ();
%   endfor
% endif
