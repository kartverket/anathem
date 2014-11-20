<%include file="/3/functions/addControlToContext.mako" />

(function (context, container) {
% if i18n:
	${i18n}
% endif

	var options = {};
	if (container) {
		options.div = container;
	}
	${self.body()}
}(controlContext, container));
