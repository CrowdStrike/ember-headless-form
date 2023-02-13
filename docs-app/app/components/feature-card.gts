import type { TOC } from '@ember/component/template-only';

const FeatureCard: TOC<{
  Element: HTMLDivElement;
  Args: { title: string; }
  Blocks: {
    default: [];
  }
}> = <template>
  <div ...attributes>
    <h4 class="pb-4 type-2xl text-titles-and-attributes">
      {{@title}}
    </h4>
    <p class="text-body-and-labels">
      {{yield}}
    </p>
  </div>
</template>;

export default FeatureCard;
