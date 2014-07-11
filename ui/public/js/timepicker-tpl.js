angular.module("template/syTimepicker/timepicker.html", []).run(["$templateCache",
  function($templateCache) {
    $templateCache.put("template/syTimepicker/timepicker.html",
      "<table>\n" +
      "	<tbody>\n" +
      "		<tr class=\"text-center\">\n" +
      "			<td><a ng-click=\"incrementHours()\" class=\"btn btn-link\"><span class=\"glyphicon glyphicon-chevron-up\"></span></a></td>\n" +
      "			<td>&nbsp;</td>\n" +
      "			<td><a ng-click=\"incrementMinutes()\" class=\"btn btn-link\"><span class=\"glyphicon glyphicon-chevron-up\"></span></a></td>\n" +
      "     <td ng-show=\"showSeconds\">&nbsp;</td>\n" +
      "     <td ng-show=\"showSeconds\"><a ng-click=\"incrementSeconds()\" class=\"btn btn-link\"><span class=\"glyphicon glyphicon-chevron-up\"></span></a></td>\n" +
      "			<td ng-show=\"showMeridian\"></td>\n" +
      "		</tr>\n" +
      "		<tr>\n" +
      "			<td style=\"width:50px;\" class=\"form-group\" ng-class=\"{'has-error': invalidHours}\">\n" +
      "				<input type=\"text\" ng-model=\"hours\" ng-change=\"updateHours()\" class=\"form-control text-center\" ng-mousewheel=\"incrementHours()\" ng-readonly=\"readonlyInput\" maxlength=\"2\">\n" +
      "			</td>\n" +
      "			<td>:</td>\n" +
      "			<td style=\"width:50px;\" class=\"form-group\" ng-class=\"{'has-error': invalidMinutes}\">\n" +
      "				<input type=\"text\" ng-model=\"minutes\" ng-change=\"updateMinutes()\" class=\"form-control text-center\" ng-readonly=\"readonlyInput\" maxlength=\"2\">\n" +
      "			</td>\n" +
      "     <td ng-show=\"showSeconds\">:</td>\n" +
      "     <td ng-show=\"showSeconds\" style=\"width:50px;\" class=\"form-group\" ng-class=\"{'has-error': invalidSeconds}\" ng-show=\"showSeconds\">\n" +
      "       <input type=\"text\" ng-model=\"seconds\" ng-change=\"updateSeconds()\" class=\"form-control text-center\" ng-readonly=\"readonlyInput\" maxlength=\"2\">\n" +
      "     </td>\n" +
      "			<td ng-show=\"showMeridian\"><button type=\"button\" class=\"btn btn-default text-center\" ng-click=\"toggleMeridian()\">{{meridian}}</button></td>\n" +
      "		</tr>\n" +
      "		<tr class=\"text-center\">\n" +
      "			<td><a ng-click=\"decrementHours()\" class=\"btn btn-link\"><span class=\"glyphicon glyphicon-chevron-down\"></span></a></td>\n" +
      "			<td>&nbsp;</td>\n" +
      "			<td><a ng-click=\"decrementMinutes()\" class=\"btn btn-link\"><span class=\"glyphicon glyphicon-chevron-down\"></span></a></td>\n" +
      "     <td ng-show=\"showSeconds\">&nbsp;</td>\n" +
      "     <td ng-show=\"showSeconds\"><a ng-click=\"decrementSeconds()\" class=\"btn btn-link\"><span class=\"glyphicon glyphicon-chevron-down\"></span></a></td>\n" +
      "			<td ng-show=\"showMeridian\"></td>\n" +
      "		</tr>\n" +
      "	</tbody>\n" +
      "</table>\n" +
      "");
  }
]);

angular.module("template/syTimepicker/popup.html", []).run(["$templateCache",
  function($templateCache) {
    $templateCache.put("template/syTimepicker/popup.html",
      "<ul class=\"dropdown-menu\" ng-style=\"{display: (isOpen && 'block') || 'none', top: position.top+'px', left: position.left+'px'}\" style=\"min-width:0px;\">\n" +
      "	<li ng-transclude></li>\n" +
      "</ul>\n" +
      "");
  }
]);