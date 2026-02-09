<template>
  <div class="overflow-hidden rounded-2xl border border-sky-100 bg-white">
    <div class="overflow-x-auto">
      <table class="min-w-full text-left text-sm">
        <thead class="bg-lightBlue/80 text-slate-700">
          <tr>
            <slot name="head" />
          </tr>
        </thead>
        <tbody>
          <slot name="body" />
        </tbody>
      </table>
    </div>
  </div>
</template>
