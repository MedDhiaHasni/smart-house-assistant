import dashboard from './dashboard';
import context from './context';
import rules from './rules';
import explain from './explain';
import modes from './modes';
import devices from './devices';
import simulator from './simulator';

export default {
  ...dashboard,
  ...context,
  ...rules,
  ...explain,
  ...modes,
  ...devices,
  ...simulator,
};
