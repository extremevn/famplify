/// MIT License
/// Copyright (c) [2020] Extreme Viet Nam
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

const resourceNotFoundException = 'ResourceNotFoundException';
const invalidParameterException = 'InvalidParameterException';
const unexpectedLambdaException = 'UnexpectedLambdaException';
const userLambdaValidationException = 'UserLambdaValidationException';
const notAuthorizedException = 'NotAuthorizedException';
const invalidPasswordException = 'InvalidPasswordException';
const usernameExistsException = 'UsernameExistsException';
const codeDeliveryFailureException = 'CodeDeliveryFailureException';
const tooManyFailedAttemptsException = 'TooManyFailedAttemptsException';
const codeMismatchException = 'CodeMismatchException';
const expiredCodeException = 'ExpiredCodeException';
const invalidLambdaResponseException = 'InvalidLambdaResponseException';
const aliasExistsException = 'AliasExistsException';
const tooManyRequestsException = 'TooManyRequestsException';
const limitExceededException = 'LimitExceededException';
const userNotFoundException = 'UserNotFoundException';
const internalErrorException = 'InternalErrorException';
const amazonClientException = 'AmazonClientException';
const amazonServiceException = 'AmazonServiceException';
const defaultException = 'DefaultException';
const apiException = 'ApiException';
const networkException = 'NetworkException';
const unknownException = 'UnknownException';

class AmplifySdkException implements Exception {
  final String code;
  final String message;

  AmplifySdkException(this.code, this.message);

  @override
  String toString() => 'Error code: $code, message: $message ';
}
