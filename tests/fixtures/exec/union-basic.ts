import createValidator from "../../../dist/typecheck.macro";
import { testBooleanValidator as tBV } from "./__helpers__";
import type { ExecutionContext } from "ava";

export default (t: ExecutionContext) => {
  const validator = createValidator<number | string>();
  tBV(t, validator, {
    inputs: [42, "hello"],
    returns: true,
  });
  tBV(t, validator, {
    inputs: [null, undefined, {}, []],
    returns: false,
  });
};
