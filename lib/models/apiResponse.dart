import 'package:jnpass/models/apiError.dart';

class ApiResponse {
  // _data will hold any response converted into 
  // its own object. For example user.
  late bool state = false;

  late Object data;
  // _apiError will hold the error object
  late ApiError apiError;

  setState(bool state2) {
    state = state2;
  }

  setData(Object data2) {
    data = data2;
  }

  setApiError(ApiError apiError2) {
    apiError = apiError2;
  }

  getState() => state;
  getData() => data;
  getApiError() => apiError;

}