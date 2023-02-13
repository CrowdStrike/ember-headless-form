self.deprecationWorkflow = self.deprecationWorkflow || {};
self.deprecationWorkflow.config = {
  workflow: [
    // @docfyc/ember violates these, but these are "fairly recent"
    { handler: 'silence', matchId: 'ember-modifier.use-modify' },
    { handler: 'silence', matchId: 'ember-modifier.no-args-property' },
  ],
};
